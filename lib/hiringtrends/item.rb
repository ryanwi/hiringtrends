# frozen_string_literal: true

module HiringTrends
  # Represents an individual hn item with associated details.
  class Item
    attr_reader :id, :created_at, :source, :title, :author, :num_comments, :points
    attr_accessor :comments

    def initialize(result)
      self.id = result["objectID"]
      self.created_at = result["created_at"]
      self.author = result["author"]
      self.title = result["title"]
      self.num_comments = result["num_comments"]
      self.points = result["points"]
    end

    def month
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(title)
      "#{match[:month][0...3]}#{match[:year][2..4]}"
    end

    def rel
      "/api/v1/items/#{id}"
    end

    private

    attr_writer :id, :created_at, :source, :title, :author, :num_comments, :points
  end
end
