# frozen_string_literal: true

require "cgi"

module HiringTrends
  class TermDiscovery
    module Parser
      STACK_LABEL = /(?:(?:our|the|current|tech(?:nology)?)\s+)*(?:stack(?:\s+includes)?|we use|technologies|tech)/i
      STACK_LINE = /\A\s*[-*•]?\s*#{STACK_LABEL}\s*[:\-–—]\s*(.+)\z/
      STACK_SEPARATORS = /\s*(?:[,;|•·]|\.\s|\band\b|&|\+)\s*/i
      ACRONYM_PAIR = %r{\A[A-Z]{1,5}/[A-Z]{1,5}\z}
      RESUME_MARKERS = [%r{r[ée]sum[ée]\s*/\s*cv\s*:}i, /willing to relocate\s*:/i,
                        /\Alocation:.*\n\s*remote:/im].freeze
      CAPITALIZED = /(?<![\w.@&-])[A-Z][A-Za-z0-9]*(?:[.+#-][A-Za-z0-9+#]+)*[+#]*(?![\w@])/
      TOKEN_SPLIT = %r{[[:space:]!|;:,.?/'()\[\]]}

      BOILERPLATE = %w[
        a about all also an and apply are as at be benefits but by can careers company competitive contract do eg etc
        for from full full-time get have help if in is it its join more new no not of on or our part-time please salary
        so that the their this time to us we what who will with year you your
        analyst architect ceo coo cto designer developer developers director eng engineer engineering engineers founder
        founding head junior lead manager principal scientist senior sr staff vp
        applied back backend data deploy deployed forward front frontend full-stack fullstack ml ops platform product
        sales security software stack systems team gtm marketing operations startup
        equity hybrid onsite pto remote usd eur gbp series yc hn news b2b b2c saas ui ux apis ci cd real-time
        integrations tools custom performance vision
        america area austin bay berlin boston ca canada chicago city dc d.c denver eu europe francisco germany india la
        london north ny nyc paris san seattle sf south states toronto u u.s uk united usa washington york amsterdam
        amazon apple google linkedin meta microsoft notion
      ].to_set.freeze

      module_function

      def clean_text(html)
        text = html.to_s.gsub(%r{<p>|<br\s*/?>}i, "\n").gsub(/<[^>]+>/, " ")
        CGI.unescapeHTML(text).gsub(/[ \t]+/, " ")
      end

      def resume?(text)
        RESUME_MARKERS.any? { |marker| text.match?(marker) }
      end

      def stack_items(text)
        lists = text.lines.filter_map { |line| line.strip[STACK_LINE, 1] }
        items = lists.flat_map { |list| split_stack_list(list) }
        items.map { |item| item.strip.sub(/[.:]+\z/, "") }.select { |item| stack_item?(item) }
      end

      def split_stack_list(list)
        cleaned = list.gsub(%r{https?://\S+}, " ").gsub(/\([^)]*\)/, " ")
        cleaned.split(STACK_SEPARATORS).flat_map { |item| item.match?(ACRONYM_PAIR) ? [item] : item.split("/") }
      end

      def stack_item?(item)
        words = item.split
        item.length.between?(2, 30) && words.size <= 3 && item.match?(/[A-Za-z]/) &&
          (words.size == 1 || words.none? { |word| word.match?(/\A[a-z]+\z/) })
      end

      def capitalized_phrases(text)
        body = text.lines.drop(1).join
        pairs = body.scan(/(?=(#{CAPITALIZED} #{CAPITALIZED}))/o).flatten
        (body.scan(CAPITALIZED) + pairs).uniq
      end

      def boilerplate?(term)
        term.downcase.split.any? { |word| BOILERPLATE.include?(word) }
      end

      def known_spellings(raw_terms)
        raw_terms.each_with_object(Set.new) do |term, known|
          name, modifier = term.split("/", 2)
          known << name.downcase
          known << "go" if name.casecmp?("golang")
          modifier_spellings(modifier).each { |spelling| known << spelling.downcase }
        end
      end

      def modifier_spellings(modifier)
        return [] unless modifier

        data = modifier[/\[(.*)\]/, 1].to_s
        modifier.start_with?("js[") ? [data, "#{data}.js", "#{data}js"] : data.split("|")
      end
    end
  end
end
