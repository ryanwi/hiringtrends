# frozen_string_literal: true

require "liquid"

module HiringTrends
  class Publisher
    attr_accessor :software_terms, :items, :item_id

    def initialize(software_terms, items, item_id)
      @software_terms = software_terms
      @items = items
      @item_id = item_id
    end

    def publish
      publish_data
      # key_measures = calculate_key_measures
      # publish_post(month, year, day, date, data_filename, key_measures)
    end

    def publish_data
      # initialize the data structure to publish, will look like
      # data = [
      # { :month => month1, num_comments => num, terms => {term1 =>
      #   { :count => 5, :percentage => .05, :rank => 1, :mavg3 => 5 }, term2 => }},
      # { :month => month2, num_comments => num, terms => {term1 =>
      #    { :count => 5, :percentage => .05, :rank => 2,, :mavg3 => 5 }, term2 => }},
      # ]
      data = []

      items.each do |item|
        record = {}
        record[:month] = ""
        record[:num_comments] = item.num_comments
        record[:points] = item.points
        record[:terms] = {}
        data << record
      end

      # File.open("web/data/#{filename}", "wb") { |f|
      #   f.write(JSON.pretty_generate(data)) }
      # end
    end

    # # def publish_post(month, year, day, date, data_filename, key_measures)
    # #   data = {
    # #     'year' => year,
    # #     'month' => month,
    # #     'day' => day,
    # #     'date' => date,
    # #     'data_filename' => data_filename,
    # #     'top_terms' => key_measures[0].take(20),
    # #     'gainers' => key_measures[1].take(10),
    # #     'losers' => key_measures[2].take(10)
    # #   }

    # #   Liquid::Template.file_system = Liquid::LocalFileSystem.new("templates")
    # #   template = File.open('templates/post.liquid', 'rb') { |f| f.read }
    # #   content = Liquid::Template.parse(template).render(data)
    # #   File.open("web/#{year}/#{month.downcase}.html", 'w') { |file| file.write(content) }
    # # end


    # def calculate_key_measures
    #   submission_keys = redis.call("ZRANGE", SUBMISSIONS_KEY, 0, -1)
    #   terms = JSON.parse(redis.call("HGET", submission_keys.first, "terms"))

    #   # Order this month's results by ranking
    #   ranked_terms = terms.sort_by { |k, v| v["rank"] }.to_a

    #   # Augment the ranking data with data from periods to compare against
    #   ranked_terms.each do |term|
    #     lm_terms = JSON.parse(redis.call("HGET", submission_keys[1], "terms"))
    #     lm_term = lm_terms[term[0]]
    #     ly_terms = JSON.parse(redis.call("HGET", submission_keys[12], "terms"))
    #     ly_term = ly_terms[term[0]]

    #     term_stats = term[1]
    #     term_stats["count_last_month"] = lm_term["count"]
    #     term_stats["count_last_year"] = ly_term["count"]
    #     term_stats["rank_last_month"] = lm_term["rank"]
    #     term_stats["rank_change_month"] = -(term_stats["rank"] - lm_term["rank"])
    #     term_stats["rank_last_year"] = ly_term["rank"]
    #     term_stats["rank_change_year"] = -(term_stats["rank"] - ly_term["rank"])
    #   end

    #   # Order by YOY rank gain, with a minimum of 5 mentions this year
    #   gainers = ranked_terms.sort_by { |te| -te[1]["rank_change_year"] }
    #   gainers.reject! { |te| te[1]["count"] < 5 }

    #   # Order by YOY rank decline, with a minimum of 5 mentions last year
    #   losers = ranked_terms.sort_by { |te| te[1]["rank_change_year"] }
    #   losers.reject! { |te| te[1]["count_last_year"] < 5 }

    #   return ranked_terms, gainers, losers
    # end
  end
end
