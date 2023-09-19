# frozen_string_literal: true

require "logger"

require_relative "hiringtrends/program"
require_relative "hiringtrends/item_search"
require_relative "hiringtrends/item"
require_relative "hiringtrends/job_posting"
require_relative "hiringtrends/publisher"

module HiringTrends
  HN_API_BASE_URL = "https://hn.algolia.com"

  def self.logger
    @logger ||= Logger.new($stdout)
  end
end
