require "redis"
require "json"
require "faraday"
require "open-uri"
require "liquid"


module HiringTrends

  class Program
    SUBMISSIONS_KEY = "hn_submissions"
    SUBMISSION_KEY_PREFIX = "submission:"

    def initialize
      @redis = Redis.new
      @software_terms = {}
    end

    # Remove data from redis
    def clean
      puts "== clean =="
      submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
      @redis.del(submission_keys) unless submission_keys.empty?
      @redis.del(SUBMISSIONS_KEY)
      self
    end

    # Remove just analysis data, not hn data
    def clean_terms
      submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
      submission_keys.each do |submission_key|
        @redis.hdel(submission_key, "terms")
      end
      self
    end

    # Initialize hash of technology terms from dictionary with 0 counts
    def initialize_dictionary
      puts "== initialize_dictionary =="
      open(@dictionary_url) {|f|
        f.each_line {|line| @software_terms[line.chomp.split("/").first] =
          {count: 0, percentage: 0, full_term: line.chomp }}
      }
      self
    end

    # Find and load all hiring submissions from HN Search API
    def get_submissions
      puts "== get_submissions =="
      submissions_url = "https://hn.algolia.com/api/v1/search_by_date?query=Who+is+hiring&tags=story,author_whoishiring"
      page = 0
      results = []
      loop do
        puts "=== page #{page} ==="
        response = Faraday.get "#{submissions_url}&page=#{page}"
        hits = JSON.parse response.body
        results += hits["hits"]
        page += 1
        break if hits["hits"].empty?
      end

      results.each do |result|
        # filter for only hiring and determine month/year
        puts result["title"]
        match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(result["title"])
        unless match.nil?
          objectID = result["objectID"]
          submission_key = "#{SUBMISSION_KEY_PREFIX}#{result["objectID"]}"
          @redis.rpush(SUBMISSIONS_KEY, submission_key)
          @redis.hmset(submission_key,
            "objectID", objectID,
            "month", "#{match[:month][0...3]}#{match[:year][2..4]}",
            "num_comments", result["num_comments"]
          )
        end
      end
      self
    end

    # Find and load all comments for the hiring submissions
    def get_comments_for_submissions
      puts "== get_comments_for_submissions =="
      submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
      submission_keys.each do |submission_key|
        # get all comments for submission from API
        submission_objectid = @redis.hget(submission_key, "objectID")
        num_comments = @redis.hget(submission_key, "num_comments")
        month = @redis.hget(submission_key, "month")

        comments = get_comments_for_submission(submission_objectid)

        # store comment text in redis
        puts "#{month}: #{comments.count} comments found..."
        @redis.hset(submission_key, "comments", comments.to_json)
        sleep 2
      end
      self
    end

    # Process all submissions, counting comments counts for each term in the technology dictionary
    def analyze_submissions(dictionary_url)
      @dictionary_url = dictionary_url
      initialize_dictionary
      submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
      submission_keys.each do |submission_key|
        # create a fresh dictionary (need a deep copy) of each term with initial count of 0
        terms = Marshal.load(Marshal.dump(@software_terms))
        raw_comments = @redis.hget(submission_key, "comments")
        comments = JSON.parse raw_comments
        term_data = analyze_submission(terms, comments)
        # store the counts
        @redis.hmset(submission_key, "terms", term_data.to_json)
      end
      self
    end

    # Find comments for individual submission
    #
    # Arguments:
    #  objectID: (String)
    def get_comments_for_submission(objectID)
      puts "== get_comments_for_submission #{objectID} =="

      # Get comments from API
      item_url = "https://hn.algolia.com/api/v1/items/#{objectID}"
      response = Faraday.get item_url
      item = JSON.parse response.body
      comments = item["children"]
    end

    # Calculate term frequency across all comments for individual submission
    #
    # Arguments:
    #  terms: (Hash)
    #  comments: (Array)
    def analyze_submission(terms, comments)
      # accumulate mentions of term as comments are searched
      comments.each do |comment|
        # extract comment text
        comment_text = comment["text"]
        next if comment_text.nil?

        hn_comment = HiringTrends::JobPosting.new(comment_text)

        # identify if each term is in the comment
        terms.keys.each do |term|
          # increment count as its found
          terms[term][:count] += 1 if hn_comment.has_term?(terms[term][:full_term])
        end
      end

      # calculate percentage of comments
      terms.keys.each do |term|
        terms[term][:percentage] = ((terms[term][:count]/comments.count.to_f) * 100).round(2)
      end

      # rank terms, order by count
      ranked_terms = terms.sort_by { |k, v| -v[:count] }.to_a
      ranked_terms.each_with_index { |item, index|
        terms[item[0]][:rank] = index+1
      }

      terms
    end

    # Publish analysis
    def publish(month, year, day, date, top_count)
      data_filename = "data-#{year}#{month}_fillin_.js"
      publish_data(year, data_filename)
      publish_page(month, year, day, date, data_filename)
      publish_top_table(top_count)
    end

  private

    # Publish a table of top terms with their relative ranks compared to last
    # month and last year
    def publish_top_table(top_count)
      submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
      month = @redis.hget(submission_keys.first, "month")
      terms = JSON.parse(@redis.hget(submission_keys.first, "terms"))
      ranked_terms = terms.sort_by { |k, v| v["rank"] }.to_a.take(top_count)

      ranked_terms.each do |term|
        lm_terms = JSON.parse(@redis.hget(submission_keys[1], "terms"))
        lm_term = lm_terms[term[0]]
        ly_terms = JSON.parse(@redis.hget(submission_keys[12], "terms"))
        ly_term = ly_terms[term[0]]

        term_stats = term[1]
        term_stats["count_last_month"] = lm_term["count"]
        term_stats["count_last_year"] = ly_term["count"]
        term_stats["rank_last_month"] = lm_term["rank"]
        term_stats["rank_change_month"] = (term_stats["rank"] - lm_term["rank"])
        term_stats["rank_last_year"] = ly_term["rank"]
        term_stats["rank_change_year"] = (term_stats["rank"] - ly_term["rank"])
      end

      data = { 'count' => top_count, 'terms' => ranked_terms }
      template = File.open('templates/top_table.liquid', 'rb') { |f| f.read }
      content = Liquid::Template.parse(template).render(data)
      File.open("web/top_table.html", 'w') { |file| file.write(content) }

      self
    end

    def publish_page(month, year, day, date, data_filename)
      data = {
        'year' => year,
        'month' => month,
        'day' => day,
        'date' => date,
        'data_filename' => data_filename,
      }

      template = File.open('templates/page.liquid', 'rb') { |f| f.read }
      content = Liquid::Template.parse(template).render(data)
      File.open("web/#{year}/#{month.downcase}.html", 'w') { |file| file.write(content) }

      self
    end

    def publish_data(year, filename)
      # initialize the data structure to publish, will look like
      # data = [
      # { :month => month1, num_comments => num, terms => {term1 =>
      #   {:count => 5, :percentage => .05 }, term2 => }},
      # { :month => month2, num_comments => num, terms => {term1 =>
      #    {:count => 5, :percentage => .05 }, term2 => }},
      # ]
      data = []

      submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
      submission_keys.each do |submission_key|
        month = @redis.hget(submission_key, "month")
        datapoint = { :month => month }
        datapoint[:num_comments] = @redis.hget(submission_key, "num_comments")

        terms = JSON.parse(@redis.hget(submission_key, "terms"))
        ranked_terms = terms.sort_by { |k, v| -v["count"] }.to_a
        ranked_terms.each_with_index{ |item, index|
          terms[item[0]]["rank"] = index+1
        }
        datapoint[:terms] = terms
        data << datapoint
      end

      File.open("web/#{year}/data/#{filename}", "wb") { |f|
        f.write(JSON.pretty_generate(data)) }
      self
    end

  end
end
