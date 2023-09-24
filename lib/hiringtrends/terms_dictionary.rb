# frozen_string_literal: true

module HiringTrends
  class TermsDictionary
    attr_reader :raw_terms, :software_terms

    def initialize(dictionary_url)
      response = Faraday.get dictionary_url
      @raw_terms = response.body.lines.map(&:chomp)
      @software_terms = {}

      @raw_terms.each do |line|
        @software_terms[line.split("/").first] = {
          count: 0,
          percentage: 0,
          mavg3: 0,
          full_term: line
        }
      end
    end

    def software_terms_clone
      Marshal.load(Marshal.dump(@software_terms))
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
