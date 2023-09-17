# frozen_string_literal: true

require "logger"
require "redis-client"

require_relative "hiringtrends/program"
require_relative "hiringtrends/item_search"
require_relative "hiringtrends/item"
require_relative "hiringtrends/job_posting"

module HiringTrends
  SUBMISSIONS_KEY = "hn_submissions"
  SUBMISSION_KEY_PREFIX = "submission:"
  HN_API_BASE_URL = "https://hn.algolia.com"

  def self.redis
    @redis ||= RedisClient.config.new_client
  end

  def self.logger
    @logger ||= Logger.new($stdout)
  end
end
