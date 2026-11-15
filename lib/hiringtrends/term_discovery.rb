# frozen_string_literal: true

require_relative "term_discovery/parser"
require_relative "term_discovery/records"

module HiringTrends
  class TermDiscovery
    SENTENCE_START = /(?:\A|[.!?:•*|>\-–—]\s*|\n\s*)\z/
    MIN_CAPITALIZED_SHARE = 0.6
    MIN_STACK_COMPANIES = 3
    MIN_RISING_COMPANIES = 5

    def initialize(recent_items:, prior_items:, raw_terms:)
      @recent = postings(recent_items)
      @prior = postings(prior_items)
      @known = Parser.known_spellings(raw_terms)
      @stack_companies = stack_companies
      @phrases = capitalized_phrases
    end

    def from_stack_lines(min_postings: 5)
      names = @stack_companies.select { |_, count| count >= MIN_STACK_COMPANIES }.keys
      build(names, min_postings).sort_by { |c| -c.recent }
    end

    def rising(min_postings: 10)
      stack_names = from_stack_lines(min_postings:).to_set(&:term)
      candidates = build(@phrases.reject { |name| stack_names.include?(name) }, min_postings)
      candidates.select { |c| rising_candidate?(c.term) }.sort_by { |c| rising_rank(c) }
    end

    def recent_count
      @recent.size
    end

    def prior_count
      @prior.size
    end

    private

    def postings(items)
      all = items.flat_map(&:comments).map { |comment| Posting.from_comment(comment) }
      all.reject { |posting| Parser.resume?(posting.text) }
    end

    def stack_companies
      found = Hash.new { |hash, key| hash[key] = Set.new }
      @recent.each_with_index do |posting, index|
        Parser.stack_items(posting.text).each { |item| found[item] << company_key(posting, index) }
      end
      merge_case_variants(found).reject { |name, _| skip?(name) }.transform_values(&:size)
    end

    def capitalized_phrases
      found = Hash.new { |hash, key| hash[key] = Set.new }
      @recent.each_with_index do |posting, index|
        Parser.capitalized_phrases(posting.text).each { |phrase| found[phrase] << index }
      end
      merge_case_variants(found).keys.reject { |name| skip?(name) }
    end

    def company_key(posting, index)
      posting.company.empty? ? index : posting.company
    end

    def merge_case_variants(found)
      found.group_by { |term, _| term.downcase }.to_h do |_, variants|
        best = variants.max_by { |term, keys| [keys.size, term.match?(/[A-Z]/) ? 1 : 0] }.first
        [best, variants.map(&:last).reduce(Set.new, :|)]
      end
    end

    def skip?(name)
      @known.include?(name.downcase) || Parser.boilerplate?(name)
    end

    def build(names, min_postings)
      names.filter_map do |term|
        recent = @recent.count { |posting| posting.mentions?(term) }
        next if recent < min_postings

        Candidate.new(term:, recent:, prior: @prior.count { |posting| posting.mentions?(term) },
                      recent_total: @recent.size, prior_total: @prior.size,
                      stack_companies: @stack_companies.fetch(term, 0))
      end
    end

    def rising_candidate?(term)
      companies_mentioning(term) >= MIN_RISING_COMPANIES && capitalized_share(term) >= MIN_CAPITALIZED_SHARE
    end

    def rising_rank(candidate)
      [candidate.prior.zero? ? 0 : 1, -(candidate.change || 0), -candidate.recent]
    end

    def companies_mentioning(term)
      matching = @recent.each_with_index.select { |posting, _| posting.mentions?(term) }
      matching.map { |posting, index| company_key(posting, index) }.uniq.size
    end

    def capitalized_share(term)
      pattern = /(?<![\w.])#{Regexp.escape(term)}(?!\w)/i
      matches = @recent.flat_map { |posting| mid_sentence_matches(posting.text, pattern) }
      matches.empty? ? 0 : matches.count(term).to_f / matches.size
    end

    def mid_sentence_matches(text, pattern)
      text.to_enum(:scan, pattern).filter_map do
        match = Regexp.last_match
        match[0] unless match.pre_match.match?(SENTENCE_START)
      end
    end
  end
end
