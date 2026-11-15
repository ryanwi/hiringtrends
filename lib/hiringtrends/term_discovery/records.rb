# frozen_string_literal: true

module HiringTrends
  class TermDiscovery
    Posting = Struct.new(:text, :lower, :company, :words) do
      def self.from_comment(comment)
        text = Parser.clean_text(comment["text"])
        lower = text.downcase
        new(text, lower, lower.lines.first.to_s.split("|").first.to_s.strip,
            lower.split(Parser::TOKEN_SPLIT).reject(&:empty?).to_set)
      end

      def mentions?(term)
        needle = term.downcase
        needle.include?(" ") || needle.include?(".") ? lower.include?(needle) : words.include?(needle)
      end
    end

    Candidate = Struct.new(:term, :recent, :prior, :recent_total, :prior_total, :stack_companies,
                           keyword_init: true) do
      def recent_share = share(recent, recent_total)
      def prior_share = share(prior, prior_total)

      def change
        return nil if prior.zero?

        recent_rate = recent.to_f / recent_total
        prior_rate = prior.to_f / prior_total
        ((recent_rate - prior_rate) / prior_rate * 100).round
      end

      private

      def share(count, total) = total.zero? ? 0.0 : (count * 100.0 / total).round(1)
    end
  end
end
