
module HiringTrends

  class Comment
    attr_accessor :text
    attr_accessor :words

    def initialize(text)
      @text = text.downcase

      # Naive tokenization of comment, build the terms contained in the comment and lower case for searching
      # todo: handle multi-word phrases (i.e. Visual Basic), with or without dot (i.e. node.js)
      @words = @text.split(/[[:space:]!|\\;:,\.\?\/'\(\)\[\]]/)
    end

    def has_term?(term)
      modifier = parse_modifier(term)

      return has_term_with_modifier?(modifier) unless modifier.nil?

      if term.include? " "
        return true if @text.downcase.scan(term.downcase).any?
      else
        return true if @words.include?(term.downcase)
      end

      return false
    end

  private

    # Some terms go by different names, modifiers are used to search for
    # different options.
    # Examples:
    # term/js[root]
    # term/alias[word1|word2]
    def parse_modifier(term)
      parts = term.split "/"
      if parts.count == 1
        return nil
      end
      return parts[1]
    end

    def has_term_with_modifier?(modifier)
      modifier_data = modifier.match(/\[(.*?)\]/).captures.first

      if modifier.start_with? "js["
        # for javascript names, get the term root and recurse over options
        return true if has_term?(modifier_data)
        return true if has_term?("#{modifier_data}.js")
        return true if has_term?("#{modifier_data}js")
      elsif modifier.start_with? "alias["
        # get the aliases and recurse
        aliases = modifier_data.split "|"
        aliases.each do |al|
          return true if has_term?(al)
        end
      end

      return false
    end

  end
end
