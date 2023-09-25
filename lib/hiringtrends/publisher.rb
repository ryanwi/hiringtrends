# frozen_string_literal: true

require "liquid"
require "debug"

module HiringTrends
  class Publisher
    attr_reader :dictionary, :items, :item_to_publish

    def initialize(item_to_publish:, items:, dictionary:)
      @dictionary = dictionary
      @items = items
      @item_to_publish = item_to_publish
    end

    def publish
      item_published_at = Time.parse(item_to_publish.created_at)
      data_filename = "data-#{item_published_at.strftime('%Y%m')}01.js"

      publish_data(data_filename)
      publish_post(item_published_at:, data_filename:)
    end

    def publish_data(filename)
      # initialize the data structure to publish, will look like
      # data = [
      # { :month => month1, num_comments => num, terms => {term1 =>
      #   { :count => 5, :percentage => .05, :rank => 1, :mavg3 => 5 }, term2 => }},
      # { :month => month2, num_comments => num, terms => {term1 =>
      #    { :count => 5, :percentage => .05, :rank => 2,, :mavg3 => 5 }, term2 => }},
      # ]
      data = []

      items.each do |item|
        record = item.to_record
        data << record
      end

      File.open("web/data/#{filename}", "wb") do |f|
        f.write("data = ")
        f.write(JSON.pretty_generate(data))
      end
    end

    def publish_post(item_published_at:, data_filename:)
      today = Time.now

      data = {
        "year" => today.year,
        "month" => today.strftime("%B"),
        "day" => today.strftime("%A"),
        "date" => today.mday,
        "data_filename" => data_filename,
        "top_terms" => [],
        "gainers" => [],
        "losers" => []
        #     'top_terms' => key_measures[0].take(20),
        #     'gainers' => key_measures[1].take(10),
        #     'losers' => key_measures[2].take(10)
      }

      Liquid::Template.file_system = Liquid::LocalFileSystem.new("templates")
      template = File.open("templates/post.liquid", "rb", &:read)
      content = Liquid::Template.parse(template).render(data)

      post_filename = "web/#{item_published_at.year}/#{item_published_at.strftime('%B').downcase}.html"
      File.open(post_filename, "w") { |file| file.write(content) }
    end

    private

    attr_writer :dictionary, :items, :item_id
  end
end
