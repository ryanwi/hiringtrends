# frozen_string_literal: true

require "faraday"
require "debug"

module HiringTrends
  class Program
    attr_accessor :dictionary_url, :item_id, :software_terms, :items

    def initialize(dictionary_url:, item_id:)
      @software_terms = {}
      @items = []
      @dictionary_url = dictionary_url
      @item_id = item_id
      initialize_dictionary
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
      item_ids.each do |id|
        item = Item.load(item_id: id)
        items << item
      end
    end

    # Process all submissions, counting comments counts for each term in the technology dictionary
    def analyze_submissions
      items.each do |item|
        item.analyze(software_terms)
      end
    end

    def publish
      Publisher.new(software_terms:, items:, item_id:).publish
    end

    private

    def initialize_dictionary
      HiringTrends.logger.info "== initialize_dictionary =="
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
  end
end
