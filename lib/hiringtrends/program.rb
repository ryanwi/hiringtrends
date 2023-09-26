# frozen_string_literal: true

require "faraday"

module HiringTrends
  # Program coordinates the execution of the program
  class Program
    attr_reader :dictionary, :item_collection, :item_id, :key_measure_calculator

    def initialize(dictionary_url:, item_id:)
      @dictionary_url = dictionary_url
      @dictionary = TermsDictionary.new(dictionary_url)
      @item_id = item_id
    end

    # Find and load all hiring submissions from HN Search API
    def fetch_all_submissions
      HiringTrends.logger.info "== searching for whoishiring submissions =="
      item_ids = ItemSearch.new.execute
      load_items(item_ids)
    end

    def fetch_submission
      Item.load(item_id:, force_api_source: true)
    end

    def load_items(item_ids)
      HiringTrends.logger.info "== loading items =="
      items = []
      item_ids.each do |id|
        items << Item.load(item_id: id)
      end
      @item_collection = ItemCollection.new(items:, target_item_id: item_id)
    end

    # Process all submissions, counting comments counts for each term in the technology dictionary
    def analyze_submissions
      item_collection.analyze(dictionary)
      @key_measure_calculator = KeyMeasureCalculator.new(item_collection:)
    end

    def publish
      Publisher.new(item_collection:, key_measure_calculator:, dictionary:).publish
    end

    private

    attr_writer :dictionary, :item_id, :item_collection, :key_measure_calculator
  end
end
