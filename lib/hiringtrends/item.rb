require "json"

module HiringTrends
  class Item
    attr_reader :id, :source, :title, :author, :num_comments

    def initialize(source)
      self.source = source
      self.id = source["objectID"]
      self.author = source["author"]
      self.num_comments = source["num_comments"]
      self.title = source["title"]
    end

    def comments
      response = Faraday.get url
      item = JSON.parse response.body
      item["children"]
    end

    def month
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(title)
      "#{match[:month][0...3]}#{match[:year][2..4]}"
    end

    private

    attr_writer :id, :source, :title, :author, :num_comments

    def url
      "#{HN_API_ROOT}/items/#{id}"
    end
  end
end
