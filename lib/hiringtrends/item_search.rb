require 'faraday'
require 'faraday_middleware'

module HiringTrends
  class ItemSearch
    def execute
      page = 0
      results = []

      loop do
        puts "=== page #{page} ==="
        response = connection.get search_url(page)
        hits = response.body
        results += hits["hits"]
        page += 1
        break if hits["hits"].empty?
      end

      results
        .select {|result| result["title"][/ask hn: who is hiring\?\s\(\w*\s\d{4}\)/i] }
        .map {|r| HiringTrends::Item.new(r)}
    end

    def search_url(page = 0)
      "/api/v1/search_by_date?query=hiring&tags=story,%28author__whoishiring,%20author_whoishiring%29&page=#{page}"
    end

    def connection
      @connection ||= Faraday.new(url: "https://hn.algolia.com") do |conn|
        conn.response :json
      end
    end
  end
end
