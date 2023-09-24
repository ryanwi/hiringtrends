# frozen_string_literal: true

require "faraday"

module HiringTrends
  class Program
    attr_reader :dictionary_url, :item_id, :dictionary, :items

    def initialize(dictionary_url:, item_id:)
      @software_terms = {}
      @items = []
      @item_id = item_id
      @dictionary_url = dictionary_url
      @dictionary = TermsDictionary.new(dictionary_url)
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
      item_ids.each do |id|
        item = Item.load(item_id: id)
        items << item
      end
    end

    # Process all submissions, counting comments counts for each term in the technology dictionary
    def analyze_submissions
      items.each do |item|
        item.analyze(dictionary)
      end
    end

    def publish
      Publisher.new(dictionary:, items:, item_id:).publish
    end

    private

    attr_writer :dictionary_url, :item_id, :dictionary, :items
  end
end
