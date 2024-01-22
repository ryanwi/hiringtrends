# frozen_string_literal: true

module HiringTrends
  # Represents the collection of items
  class ItemCollection
    include Enumerable

    attr_reader :items, :target_item_id

    def initialize(items:, target_item_id:)
      @items = items
      @target_item_id = target_item_id
    end

    def count
      items.count
    end

    def each(&)
      items.each(&)
    end

    def target_item
      @target_item ||= items.find { |item| item.id == target_item_id.to_i }
    end

    def target_item_created_at
      target_item&.created_at
    end

    def analyze(dictionary)
      items.each do |item|
        item.analyze(dictionary)
      end
    end

    def add(item)
      @items.push(item)
    end

    def last_year
      items[12]
    end

    def last_month
      items[1]
    end

    def last_year_terms_data
      last_year&.terms_data || {}
    end

    def last_month_terms_data
      last_month&.terms_data || {}
    end

    private

    attr_writer :items, :target_item_id
  end
end
