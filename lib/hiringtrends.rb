# frozen_string_literal: true

require "logger"

require "hiringtrends/item"
require "hiringtrends/item_collection"
require "hiringtrends/item_search"
require "hiringtrends/job_posting"
require "hiringtrends/key_measure_calculator"
require "hiringtrends/program"
require "hiringtrends/publisher"
require "hiringtrends/terms_dictionary"

module HiringTrends
  HN_API_BASE_URL = "https://hn.algolia.com"

  def self.logger
    @logger ||= Logger.new($stdout)
  end
end
