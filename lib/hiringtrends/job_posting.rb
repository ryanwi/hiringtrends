# frozen_string_literal: true

module HiringTrends
  # Represents a job posting from an HN comment that can be searched against
  class JobPosting
    attr_reader :original_text, :text

    def initialize(job_description:)
      @original_text = job_description
      @text = job_description.downcase
    end

    def term?(term)
      modifier = TermsDictionary.parse_modifier(term)

      return term_with_modifier?(modifier) if modifier

      search_term = term.downcase
      return true if term_in_text?(search_term)
      return true if term_special_cases?(search_term)

      false
    end

    private

    attr_writer :original_text, :text

    # Naive tokenization of comment, build the terms contained in the comment and lower case for searching
    # For multi-word phrases (e.g. Visual Basic), search directly against the comment string.
    def words
      @words ||= text.split(/[[:space:]!|\\;:,.?\/'()\[\]]/).map(&:strip).reject(&:empty?).map(&:downcase)
    end

    def original_words
      @original_words ||= original_text.split(/[[:space:]!|\\;:,.?\/'()\[\]]/)
    end

    def term_in_text?(term)
      if term.include?(" ") || term.include?(".")
        # For multi-word phrases (e.g. Visual Basic), search directly against the comment string.
        return true if text.include?(term)
      elsif words.include?(term)
        return true
      end

      false
    end

    def term_special_cases?(term)
      return true if term == "golang" && original_words.include?("Go")

      false
    end

    def term_with_modifier?(modifier)
      modifier_data = modifier.match(/\[(.*?)\]/).captures.first

      if modifier.start_with?("js[")
        search_js_variations(modifier_data)
      elsif modifier.start_with?("alias[")
        search_alias_variations(modifier_data)
      else
        false
      end
    end

    def search_js_variations(data)
      [data, "#{data}.js", "#{data}js"].any? { |variation| term?(variation) }
    end

    def search_alias_variations(data)
      data.split("|").any? { |a| term?(a) }
    end
  end
end
