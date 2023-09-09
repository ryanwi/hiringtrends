# frozen_string_literal: true

module HiringTrends
  class Item
    attr_reader :id, :created_at, :source, :title, :author, :num_comments
    attr_accessor :comments

    def initialize(id, created_at, author, num_comments, title)
      self.id = id
      self.created_at = created_at
      self.author = author
      self.num_comments = num_comments
      self.title = title
    end

    def month
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(title)
      "#{match[:month][0...3]}#{match[:year][2..4]}"
    end

    def rel
      "/api/v1/items/#{id}"
    end

    private

    attr_writer :id, :created_at, :source, :title, :author, :num_comments
  end
end
