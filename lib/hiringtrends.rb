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
    submissions_url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][username]=whoishiring&limit=100&sortby=create_ts+desc&filter[fields][type]=submission"
    response = Faraday.get submissions_url
    hn_search = JSON.parse response.body
    hn_search["results"].each do |result|
      # filter for only hiring and determine month/year
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(result["item"]["title"])
      unless match.nil?
        sigid = result["item"]["_id"]
        num_comments = result["item"]["num_comments"]
        submission_key = "#{SUBMISSION_KEY_PREFIX}#{sigid}"
        @redis.rpush(SUBMISSIONS_KEY, submission_key)
        @redis.hmset(submission_key, "sigid", sigid, "month", "#{match[:month]}#{match[:year]}", "num_comments", num_comments)
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
      submission_sigid = @redis.hget(submission_key, "sigid")
      num_comments = @redis.hget(submission_key, "num_comments")
      month = @redis.hget(submission_key, "month")

      comments = get_comments_for_submission(submission_sigid, num_comments)

      # store comment text in redis
      puts "#{month}: #{comments.count} comments found..."
      @redis.hset(submission_key, "comments", comments.to_json)
    end
    self
  end

  # Process all submissions, counting comments counts for each term in the technology dictionary
  def analyze_submissions(dictionary_url)
    @dictionary_url = dictionary_url
    initialize_dictionary if @software_terms.empty?
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
  #  sigid: (String)
  #  num_comments: (Integer)
  def get_comments_for_submission(sigid, num_comments)
    puts "== get_comments_for_submission #{sigid} =="

    # accumulate comments across all pages
    comments = []
    pages = (num_comments.to_f / 100).ceil

    # Get comments from API and page results as necessary
    for j in 0...pages
      start = j*100
      comments_url = "http://api.thriftdb.com/api.hnsearch.com/items/_search?limit=100&start=#{start}&filter[fields][discussion.sigid]=#{sigid}&filter[fields][type]=comment&sortby=create_ts+desc"
      response = Faraday.get comments_url
      comments_results = JSON.parse response.body
      comments.concat(comments_results["results"])
    end

    comments
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
      comment_text = comment["item"]["text"]

      # Naive tokenization of comment, build the terms contained in the comment and lower case for searching
      # todo: handle multi-word phrases (i.e. Visual Basic), with or without dot (i.e. node.js)
      comment_words = comment_text.split(/[[:space:]!|;:,\.\?\/'\(\)\[\]]/).map(&:downcase)

      # identify if each term is in the comment
      terms.keys.each do |term|
        # increment count as its found
        terms[term][:count] += 1 if comment_words.include?( term.downcase )
        # terms[term][:count] += 1 if comment_text.downcase.scan(term.downcase).any?
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
