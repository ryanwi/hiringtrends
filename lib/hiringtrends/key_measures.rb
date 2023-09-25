# frozen_string_literal: true

module HiringTrends
  class KeyMeasures
    def initalize
    end

    def calculate_key_measures
      # # Order this month's results by ranking
      # ranked_terms = item.terms_data.sort_by { |_, data| data[:rank] }.to_a

      # # Augment the ranking data with data from periods to compare against
      # ranked_terms.each do |term|
      #   # lm_terms = JSON.parse(redis.call("HGET", submission_keys[1], "terms"))
      #   # lm_term = lm_terms[term[0]]
      #   # ly_terms = JSON.parse(redis.call("HGET", submission_keys[12], "terms"))
      #   # ly_term = ly_terms[term[0]]

      #   # term_stats = term[1]
      #   # term_stats["count_last_month"] = lm_term["count"]
      #   # term_stats["count_last_year"] = ly_term["count"]
      #   # term_stats["rank_last_month"] = lm_term["rank"]
      #   # term_stats["rank_change_month"] = -(term_stats["rank"] - lm_term["rank"])
      #   # term_stats["rank_last_year"] = ly_term["rank"]
      #   # term_stats["rank_change_year"] = -(term_stats["rank"] - ly_term["rank"])
      # end

      # # Order by YOY rank gain, with a minimum of 5 mentions this year
      # # gainers = ranked_terms.sort_by { |te| -te[1]["rank_change_year"] }
      # # gainers.reject! { |te| te[1]["count"] < 5 }

      # # Order by YOY rank decline, with a minimum of 5 mentions last year
      # # losers = ranked_terms.sort_by { |te| te[1]["rank_change_year"] }
      # # losers.reject! { |te| te[1]["count_last_year"] < 5 }

      # # return ranked_terms, gainers, losers
    end

  end
end
