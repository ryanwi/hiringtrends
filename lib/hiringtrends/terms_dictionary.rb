# frozen_string_literal: true

module HiringTrends
  class TermsDictionary
    attr_reader :raw_terms

    def initialize(source)
      body = File.exist?(source) ? File.read(source) : Faraday.get(source).body
      @raw_terms = body.lines.map(&:chomp).reject(&:empty?)
      @term_counts_template = @raw_terms.each_with_object({}) do |term, result|
        term_without_modifiers = term.split("/").first
        result[term_without_modifiers] = {
          "count" => 0,
          "percentage" => 0,
          "rank" => 0,
          "full_term" => term
        }
      end
    end

    # Returns a copy of the term counts template
    def term_counts_template
      Marshal.load(Marshal.dump(@term_counts_template))
    end

    # Some terms go by different names, modifiers are used to search for
    # different options.
    # Examples:
    # term/js[root]
    # term/alias[word1|word2]
    def self.parse_modifier(term)
      parts = term.split "/"
      return nil if parts.count == 1

      parts[1]
    end
  end
end
