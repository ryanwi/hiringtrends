# frozen_string_literal: true

require "redis-client"
require_relative "hiringtrends/program"
require_relative "hiringtrends/item_search"
require_relative "hiringtrends/item"
require_relative "hiringtrends/job_posting"

module HiringTrends
  SUBMISSIONS_KEY = "hn_submissions"
  SUBMISSION_KEY_PREFIX = "submission:"
  HN_API_ROOT = "https://hn.algolia.com/api/v1"

  def self.redis
    @redis ||= RedisClient.config.new_client
  end
end
