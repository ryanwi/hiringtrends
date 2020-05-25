module HiringTrends
  class ItemSearch
    def execute
      page = 0
      results = []

      loop do
        puts "=== page #{page} ==="
        response = Faraday.get "#{url}&page=#{page}"
        hits = JSON.parse response.body
        results += hits["hits"]
        page += 1
        break if hits["hits"].empty?
      end

      results
        .select {|result| result["title"][/ask hn: who is hiring\?\s\(\w*\s\d{4}\)/i] }
        .map {|r| HiringTrends::Item.new(r)}
    end

    def url
      "#{HN_API_ROOT}/search_by_date?query=hiring&tags=story,%28author__whoishiring,%20author_whoishiring%29"
    end
  end
end
