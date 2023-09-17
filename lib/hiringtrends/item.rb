# frozen_string_literal: true

module HiringTrends
  # Represents an individual hn item with associated details.
  class Item
    attr_reader :id, :created_at, :source, :title, :author, :num_comments, :points, :terms
    attr_accessor :comments

    def initialize(result)
      self.id = result["objectID"]
      self.created_at = result["created_at"]
      self.author = result["author"]
      self.title = result["title"]
      self.num_comments = result["num_comments"]
      self.points = result["points"]
    end

    def month
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(title)
      "#{match[:month][0...3]}#{match[:year][2..4]}"
    end

    def rel
      "/api/v1/items/#{id}"
    end

    def analyze(comments:, terms:)
      HiringTrends.logger.info "== Analyzing #{title} =="
      @comments = comments
      @terms = terms

      count_terms_in_comments
      calculate_percentage_for_terms
      rank_terms_by_count
    end

    private

    attr_writer :id, :created_at, :source, :title, :author, :num_comments, :points

    # accumulate mentions of term as comments are searched
    def count_terms_in_comments
      comments.each do |comment|
        comment_text = comment["text"]
        next if comment_text.nil?

        posting = HiringTrends::JobPosting.new(comment_text)

        # identify if each term is in the comment
        terms.each_key do |term|
          # increment count as its found
          terms[term][:count] += 1 if posting.term?(terms[term][:full_term])
        end
      end
    end

    def calculate_percentage_for_terms
      terms.each_key do |term|
        terms[term][:percentage] = ((terms[term][:count] / comments.count.to_f) * 100).round(2)
      end
    end

    def rank_terms_by_count
      ranked_terms = terms.sort_by { |_k, v| -v[:count] }.to_a
      ranked_terms.each_with_index { |item, index| terms[item[0]][:rank] = index + 1 }
    end
  end
end
