# frozen_string_literal: true

require "json"
require "faraday"
require "liquid"
require "typhoeus"
require "debug"

module HiringTrends
  class Program
    def initialize(dictionary_url)
      self.software_terms = {}
      self.dictionary_url = dictionary_url
      initialize_dictionary
    end

    # Remove data from redis
    def clean
      puts "== removing all data from redis =="
      submission_keys = redis.lrange(SUBMISSIONS_KEY, 0, -1)
      redis.del(submission_keys) unless submission_keys.empty?
      redis.del(SUBMISSIONS_KEY)
    end

    # Remove just analysis data, not hn data
    def clean_terms
      submission_keys = redis.lrange(SUBMISSIONS_KEY, 0, -1)
      submission_keys.each do |submission_key|
        redis.hdel(submission_key, "terms")
      end
    end

    # Initialize hash of technology terms from dictionary with 0 counts
    def initialize_dictionary
      puts "== initialize_dictionary =="
      response = Faraday.get dictionary_url
      response.body.lines.each do |line|
        software_terms[line.chomp.split("/").first] = {
          count: 0,
          percentage: 0,
          mavg3: 0,
          full_term: line.chomp
        }
      end
    end

    # Find and load all hiring submissions from HN Search API
    def get_submissions
      puts "== searching for whoishiring submissions =="
      @items ||= HiringTrends::ItemSearch.new.execute
    end

    def get_comments_for_submissions
      puts "== retrieving comments from API in parallel =="
      manager = Typhoeus::Hydra.new(:max_concurrency => 10)
      conn = Faraday.new(url: "https://hn.algolia.com") do |builder|
        builder.response :logger
        builder.response :json
        builder.adapter  :typhoeus
      end

      responses = []
      conn.in_parallel(manager) do
        @items.each { |item| responses << conn.get(item.rel) }
      end

      puts "== loading comments into items =="
      @items.each do |item|
        begin
          item.comments = responses
            .find { |response| response.body.fetch("id") == item.id.to_i }
            .body
            .fetch("children")
        rescue NoMethodError => e
          binding.break
        end
      end
    end

    def save_submissions
      puts "== persisting to redis =="
      @items.each do |item|
        puts item.title
        submission_key = "#{SUBMISSION_KEY_PREFIX}#{item.id}"
        redis.rpush(SUBMISSIONS_KEY, submission_key)
        redis.hmset(submission_key,
          "objectID", item.id,
          "month", item.month
        )

        puts "#{item.id}: #{item.comments.count} comments found..."
        begin
          redis.hmset(submission_key,
            "comments", item.comments.to_json,
            "num_comments", item.comments.count
          )
        rescue => e
          binding.break
        end
      end
    end

    # Process all submissions, counting comments counts for each term in the technology dictionary
    def analyze_submissions
      submission_keys = redis.lrange(SUBMISSIONS_KEY, 0, -1)

      # Process oldest to newest
      processed_keys = []
      submission_keys.reverse.each_with_index do |submission_key, index|
        puts "== Analyzing #{redis.hget(submission_key, "month")} =="

        # create a fresh dictionary (need a deep copy) of each term with initial count of 0
        terms = Marshal.load(Marshal.dump(software_terms))
        raw_comments = redis.hget(submission_key, "comments")
        comments = JSON.parse raw_comments
        term_data = analyze_submission(terms, comments, processed_keys.count >= 2 ? processed_keys.last(2) : [])
        # store the counts
        redis.hset(submission_key, "terms", term_data.to_json)
        processed_keys << submission_key
      end
      self
    end

    # Calculate term frequency across all comments for individual submission
    #
    # Arguments:
    #  terms: (Hash)
    #  comments: (Array)
    def analyze_submission(terms, comments, previous_submission_keys)
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

      # moving average to smooth chart
      unless previous_submission_keys.empty?
        one_month_previous_terms = JSON.parse(redis.hget(previous_submission_keys[0], "terms"))
        two_month_previous_terms = JSON.parse(redis.hget(previous_submission_keys[1], "terms"))
        terms.keys.each do |term|
          terms[term][:mavg3] = (terms[term][:count] +
            one_month_previous_terms[term]["count"] +
            two_month_previous_terms[term]["count"]) / 3
        end
      end

      # rank terms, order by count
      ranked_terms = terms.sort_by { |k, v| -v[:count] }.to_a
      ranked_terms.each_with_index { |item, index|
        terms[item[0]][:rank] = index+1
      }

      terms
    end

    # Publish analysis
    def publish(month, year, day, date)
      data_filename = "data-#{year}#{month}_fillin_"
      publish_data(year, data_filename)

      key_measures = calculate_key_measures

      publish_index(month, year, day, date, key_measures)
      publish_post(month, year, day, date, data_filename, key_measures)
    end

  private

    attr_accessor :redis, :software_terms, :dictionary_url

    def redis
      HiringTrends.redis
    end

    def calculate_key_measures
      submission_keys = redis.lrange(SUBMISSIONS_KEY, 0, -1)
      terms = JSON.parse(redis.hget(submission_keys.first, "terms"))

      # Order this month's results by ranking
      ranked_terms = terms.sort_by { |k, v| v["rank"] }.to_a

      # Augment the ranking data with data from periods to compare against
      ranked_terms.each do |term|
        lm_terms = JSON.parse(redis.hget(submission_keys[1], "terms"))
        lm_term = lm_terms[term[0]]
        ly_terms = JSON.parse(redis.hget(submission_keys[12], "terms"))
        ly_term = ly_terms[term[0]]

        term_stats = term[1]
        term_stats["count_last_month"] = lm_term["count"]
        term_stats["count_last_year"] = ly_term["count"]
        term_stats["rank_last_month"] = lm_term["rank"]
        term_stats["rank_change_month"] = -(term_stats["rank"] - lm_term["rank"])
        term_stats["rank_last_year"] = ly_term["rank"]
        term_stats["rank_change_year"] = -(term_stats["rank"] - ly_term["rank"])
      end

      # Order by YOY rank gain, with a minimum of 5 mentions this year
      gainers = ranked_terms.sort_by { |te| -te[1]["rank_change_year"] }
      gainers.reject! { |te| te[1]["count"] < 5 }

      # Order by YOY rank decline, with a minimum of 5 mentions last year
      losers = ranked_terms.sort_by { |te| te[1]["rank_change_year"] }
      losers.reject! { |te| te[1]["count_last_year"] < 5 }

      return ranked_terms, gainers, losers
    end

    def publish_index(month, year, day, date, key_measures)
      data = {
        'year' => year,
        'month' => month,
        'day' => day,
        'date' => date,
        'top_terms' => key_measures[0].take(20),
        'gainers' => key_measures[1].take(10),
        'losers' => key_measures[2].take(10)
      }

      Liquid::Template.file_system = Liquid::LocalFileSystem.new("templates")
      template = File.open('templates/index.liquid', 'rb') { |f| f.read }
      content = Liquid::Template.parse(template).render(data)
      File.open("web/index.html", 'w') { |file| file.write(content) }
    end

    def publish_post(month, year, day, date, data_filename, key_measures)
      data = {
        'year' => year,
        'month' => month,
        'day' => day,
        'date' => date,
        'data_filename' => data_filename,
        'top_terms' => key_measures[0].take(20),
        'gainers' => key_measures[1].take(10),
        'losers' => key_measures[2].take(10)
      }

      Liquid::Template.file_system = Liquid::LocalFileSystem.new("templates")
      template = File.open('templates/post.liquid', 'rb') { |f| f.read }
      content = Liquid::Template.parse(template).render(data)
      File.open("web/#{year}/#{month.downcase}.html", 'w') { |file| file.write(content) }
    end

    def publish_data(year, filename)
      # initialize the data structure to publish, will look like
      # data = [
      # { :month => month1, num_comments => num, terms => {term1 =>
      #   { :count => 5, :percentage => .05, :rank => 1, :mavg3 => 5 }, term2 => }},
      # { :month => month2, num_comments => num, terms => {term1 =>
      #    { :count => 5, :percentage => .05, :rank => 2,, :mavg3 => 5 }, term2 => }},
      # ]
      data = []

      submission_keys = redis.lrange(SUBMISSIONS_KEY, 0, -1)
      submission_keys.each do |submission_key|
        datapoint = { :month => redis.hget(submission_key, "month") }
        datapoint[:num_comments] = redis.hget(submission_key, "num_comments")
        datapoint[:terms] = JSON.parse(redis.hget(submission_key, "terms"))
        data << datapoint
      end

      File.open("web/#{year}/data/#{filename}", "wb") { |f|
        f.write(JSON.pretty_generate(data)) }
      self
    end
  end
end
