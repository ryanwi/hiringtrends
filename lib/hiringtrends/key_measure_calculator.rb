# frozen_string_literal: true

module HiringTrends
  # Represents the key measures calculated from the collection of items and the item we are analyzing
  class KeyMeasureCalculator
    attr_reader :item_collection

    def initialize(item_collection:)
      @item_collection = item_collection
      calculate_key_measures
    end

    def ranked_terms
      item_collection
        .target_item
        .terms_data
        .sort_by { |_, data| data["rank"] }
        .to_h
    end

    def top_terms(limit)
      ranked_terms
        .first(limit)
        .to_h
    end

    def top_gainers(limit)
      # Order by YOY rank gain, with a minimum of 5 mentions this year
      # gainers = ranked_terms.sort_by { |te| -te[1]["rank_change_year"] }
      # gainers.reject! { |te| te[1]["count"] < 5 }
      [].first(limit)
    end

    def top_losers(limit)
      # Order by YOY rank decline, with a minimum of 5 mentions last year
      # losers = ranked_terms.sort_by { |te| te[1]["rank_change_year"] }
      # losers.reject! { |te| te[1]["count_last_year"] < 5 }
      [].first(limit)
    end

    private

    def calculate_key_measures
      ranked_terms.each do |term, term_data|
        join_counts(term, term_data)
        join_ranks(term, term_data)
        term_data["rank_change_month"] = -(term_data["rank"] - term_data["rank_last_month"])
        term_data["rank_change_year"] = -(term_data["rank"] - term_data["rank_last_year"])
      end
    end

    def join_counts(term, term_data)
      term_data["count_last_month"] = item_collection.last_month_terms_data[term]["count"]
      term_data["count_last_year"] = item_collection.last_year_terms_data[term]["count"]
    end

    def join_ranks(term, term_data)
      term_data["rank_last_month"] = item_collection.last_month_terms_data[term]["rank"]
      term_data["rank_last_year"] = item_collection.last_year_terms_data[term]["rank"]
    end
  end
end
