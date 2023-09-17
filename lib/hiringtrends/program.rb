# frozen_string_literal: true

require "json"
require "faraday"
require "typhoeus"
require "faraday/typhoeus"

module HiringTrends
  class Program
    attr_accessor :software_terms, :dictionary_url, :items, :comment_responses

    def initialize(dictionary_url)
      @software_terms = {}
      @dictionary_url = dictionary_url
      initialize_dictionary
    end

    # Find and load all hiring submissions from HN Search API
    def fetch_submissions
      HiringTrends.logger.info "== searching for whoishiring submissions =="

      @items = HiringTrends::ItemSearch.new.execute
      fetch_comments_for_submissions
    end

    # Process all submissions, counting comments counts for each term in the technology dictionary
    def analyze_submissions
      items.each do |item|
        comments = comment_responses.find { |response| response.body.fetch("id") == item.id.to_i }.body.fetch("children")
        # create a fresh dictionary (need a deep copy) of each term with initial count of 0
        terms = Marshal.load(Marshal.dump(software_terms))
        item.analyze(comments: comments, terms: terms)
      end
    end

    def publish(item_id:)
      publisher = Publisher.new(software_terms, items, item_id)
      publisher.publish
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

    def fetch_comments_for_submissions
      HiringTrends.logger.info "== retrieving comments from API in parallel =="

      manager = Typhoeus::Hydra.new(max_concurrency: 10)
      conn = Faraday.new(url: HiringTrends::HN_API_BASE_URL) do |builder|
        builder.response :logger
        builder.response :json
        builder.adapter  :typhoeus
      end

      @comment_responses = []
      conn.in_parallel(manager) do
        items.each { |item| @comment_responses << conn.get(item.rel) }
      end
    end
  end
end
