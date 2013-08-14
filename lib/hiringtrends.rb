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

  # Initialize hash of technology terms from dictionary with 0 counts
  def initialize_dictionary
    puts "== initialize_dictionary =="
    open("https://gist.github.com/ryanwi/6135845/raw/06e8ab0f2e1815c3bb841c49aa93ad82ccb1cc60/software-terms.dic") {|f|
      f.each_line {|line| @software_terms[line.chomp] = {:count => 0, :percentage => 0}}
    }
  end

  # Remove data from redis
  def clean
    puts "== clean =="
    submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
    @redis.del(submission_keys) unless submission_keys.empty?
    @redis.del(SUBMISSIONS_KEY)
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
  end

  # Find comments for individual submission
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

  # Process submission
  def analyze_submission(submission_key)
    raw_comments = @redis.hget(submission_key, "comments")
    comments = JSON.parse raw_comments

    # create a fresh dictionary of each term with initial count of 0
    terms = @software_terms.clone

    comments.each do |comment|
      # extract comment text
      comment_text = comment["item"]["text"]

      # the terms/phrases contained in the comment
      # todo, handle phrases, with or without .
      comment_words = comment_text.split(/[ ,\/]/)

      # identify if each term is in the comment
      terms.keys.each do |term|
        # increment count as its found
        terms[term][:count] += 1 if comment_has_term?(term, comment_words)
      end
    end

    # calculate percentage of comments
    terms.keys.each do |term|
      terms[term][:percentage] = terms[term][:count]/comments.count.to_f
    end

    # store the counts
    @redis.hmset(submission_key, "terms", terms.to_json)
  end

  # Search, case-insensitive, the comment words array for a given word
  def comment_has_term?(word, comment_words)
    downword = word.downcase
    comment_words.each do |c|
      return true if (c.downcase == downword)
    end
    false
  end

  # Process all submissions, counting comments counts for each term in the technology dictionary
  def analyze_submissions
    initialize_dictionary if @software_terms.empty?
    submission_keys = @redis.lrange(SUBMISSIONS_KEY, 0, -1)
    submission_keys.each do |submission_key|
      analyze_submission(submission_key)
    end
  end

end
