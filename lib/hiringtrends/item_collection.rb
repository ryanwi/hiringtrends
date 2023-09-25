# frozen_string_literal: true

module HiringTrends
  class ItemCollection
    include Enumerable

    attr_accessor :items
    attr_reader :target_item_id

    def initialize(target_item_id:)
      @items = []
      @target_item_id = target_item_id
    end

    def count
      items.count
    end

    def each(&block)
      items.each(&block)
    end

    def target_item
      @target_item ||= items.find { |item| item.id == target_item_id.to_i }
    end

    def analyze!
      items.each do |item|
        item.analyze(dictionary)
      end
    end

    def add(item)
      @items.push(item)
    end

    def last_year
      items[1]
    end

    def last_month
      items[12]
    end

    def last_year_terms_data
      last_year.terms_data
    end

    def last_month_terms_data
      last_month.terms_data
    end
  end
end
