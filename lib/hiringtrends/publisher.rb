# frozen_string_literal: true

require "liquid"
require "debug"

module HiringTrends
  class Publisher
    attr_reader :item_collection, :key_measure_calculator, :dictionary

    def initialize(item_collection:, key_measure_calculator:, dictionary:)
      @item_collection = item_collection
      @key_measure_calculator = key_measure_calculator
      @dictionary = dictionary
    end

    def publish
      item_published_at = Time.parse(item_collection.target_item_created_at)
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

      item_collection.each do |item|
        record = item.to_record
        data << record
      end

      File.open("web/data/#{filename}", "wb") do |f|
        f.write("data = ")
        f.write(JSON.pretty_generate(data))
      end
    end

    def publish_post(item_published_at:, data_filename:)
      Liquid::Template.file_system = Liquid::LocalFileSystem.new("templates")
      template = File.open("templates/post.liquid", "rb", &:read)
      content = Liquid::Template.parse(template).render(post_template_variables)
      post_filename = "web/#{item_published_at.year}/#{item_published_at.strftime('%B').downcase}.html"
      File.open(post_filename, "w") { |file| file.write(content) }
    end

    private

    attr_writer :item_collection, :key_measure_calculator, :dictionary

    def post_template_variables
      today = Time.now

      {
        "year" => today.year,
        "month" => today.strftime("%B"),
        "day" => today.strftime("%A"),
        "date" => today.mday,
        "data_filename" => data_filename,
        "top_terms" => key_measure_calculator.top_terms(20),
        "gainers" => key_measure_calculator.top_gainers(10),
        "losers" => key_measure_calculator.top_losers(10)
      }
    end
  end
end
