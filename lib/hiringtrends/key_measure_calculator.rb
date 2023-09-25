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
        .sort_by { |_, data| data[:rank] }
        .to_h
    end

    def top_terms(limit)
      ranked_terms
        .first(limit)
        .to_h
    end

    def top_gainers(limit)
      []
    end

    def top_losers(limit)
      []
    end

    def calculate_key_measures
      # Augment the ranking data with data from periods to compare against
      ranked_terms.each do |term|
        lm_term = item_collection.last_month_terms_data[term]
        ly_term = item_collection.last_year_terms_data[term]

        # term_stats = term[1]
        # term_stats["count_last_month"] = lm_term["count"]
        # term_stats["count_last_year"] = ly_term["count"]
        # term_stats["rank_last_month"] = lm_term["rank"]
        # term_stats["rank_change_month"] = -(term_stats["rank"] - lm_term["rank"])
        # term_stats["rank_last_year"] = ly_term["rank"]
        # term_stats["rank_change_year"] = -(term_stats["rank"] - ly_term["rank"])
      end

      # Order by YOY rank gain, with a minimum of 5 mentions this year
      # gainers = ranked_terms.sort_by { |te| -te[1]["rank_change_year"] }
      # gainers.reject! { |te| te[1]["count"] < 5 }

      # Order by YOY rank decline, with a minimum of 5 mentions last year
      # losers = ranked_terms.sort_by { |te| te[1]["rank_change_year"] }
      # losers.reject! { |te| te[1]["count_last_year"] < 5 }

      ranked_terms
    end
  end
end
