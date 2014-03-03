require "redis"
require "json"
require "faraday"
require "open-uri"


class HiringTrends
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

  # Initialize hash of technology terms from dictionary with 0 counts
  def initialize_dictionary
    puts "== initialize_dictionary =="
    open(@dictionary_url) {|f|
      f.each_line {|line| @software_terms[line.chomp] = {:count => 0, :percentage => 0}}
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
        puts "match"
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

      # Naive tokenization of comment, build the terms contained in the comment and lower case for searching
      # todo: handle multi-word phrases (i.e. Visual Basic), with or without dot (i.e. node.js)
      comment_words = comment_text.split(/[[:space:]!|;:,\.\?\/'\(\)\[\]]/).map(&:downcase)

      # identify if each term is in the comment
      terms.keys.each do |term|
        # increment count as its found
        if term.include? " "
          terms[term][:count] += 1 if comment_text.downcase.scan( term.downcase ).any?
        else
          terms[term][:count] += 1 if comment_words.include?( term.downcase )
        end
      end
    end

    # calculate percentage of comments
    terms.keys.each do |term|
      terms[term][:percentage] = ((terms[term][:count]/comments.count.to_f) * 100).round(2)
    end

    terms
  end

  # Publish analysis
  def publish(filename)
    initialize_dictionary if @software_terms.empty?

    # initialize the data structure to publish, will look like
    # data = [
    # { :month => month1, num_comments => num, terms => {term1 => {:count => 5, :percentage => .05 }, term2 => }},
    # { :month => month2, num_comments => num, terms => {term1 => {:count => 5, :percentage => .05 }, term2 => }},
    # ]
    data = []

    submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
    submission_keys.each do |submission_key|
      month = @redis.hget(submission_key, "month")
      datapoint = { :month => month }
      datapoint[:num_comments] = @redis.hget(submission_key, "num_comments")
      datapoint[:terms] = JSON.parse(@redis.hget(submission_key, "terms"))
      data << datapoint
    end

    File.open(filename, "wb") { |f| f.write(JSON.pretty_generate(data)) }

    self
  end

end
