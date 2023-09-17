# frozen_string_literal: true

require "faraday"

module HiringTrends
  # Represents a HN API search for "Ask HN: Who is hiring?" items
  class ItemSearch
    def execute
      results = fetch_results
      filter_and_map_results(results)
    end

    private

    def fetch_results
      page = 0
      results = []

      loop do
        puts "=== page #{page} ==="
        response = conn.get search_url(page)
        hits = response.body
        results += hits["hits"]
        page += 1
        break if hits["hits"].empty?
      end

      results
    end

    def filter_and_map_results(results)
      results
        .select { |result| result["title"][/ask hn: who is hiring\?\s\(\w*\s\d{4}\)/i] }
        .map { |result| HiringTrends::Item.new(result) }
    end

    def search_url(page = 0)
      "/api/v1/search_by_date?query=hiring&tags=story,%28author__whoishiring,%20author_whoishiring%29&page=#{page}"
    end

    def conn
      @conn ||= Faraday.new(url: HN_API_BASE_URL) do |builder|
        builder.response :json
      end
    end
  end
end
