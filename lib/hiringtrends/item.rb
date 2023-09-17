# frozen_string_literal: true

module HiringTrends
  # Represents an individual hn item with associated details.
  class Item
    attr_accessor :id, :comments, :created_at, :source, :title, :author, :num_comments, :points, :terms


    def initialize(result)
      @id = result["objectID"] || result["id"]
      @created_at = result["created_at"]
      @author = result["author"]
      @title = result["title"]
      @num_comments = result["num_comments"]
      @points = result["points"]

      @comments = result["children"] if result.key?("children")
    end

    def month
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(title)
      "#{match[:month][0...3]}#{match[:year][2..4]}"
    end

    def rel
      "/api/v1/items/#{id}"
    end

    def save
      File.open("data/item_#{id}.json", "wb") do |f|
        f.write(to_h.to_json)
      end
    end

    def analyze(terms)
      HiringTrends.logger.info "== Analyzing #{title} =="
      @terms = terms

      count_terms_in_comments
      calculate_percentage_for_terms
      rank_terms_by_count
    end

    def to_h
      {
        id: id,
        created_at: created_at,
        source: source,
        title: title,
        author: author,
        num_comments: num_comments,
        points: points,
        comments: comments
      }
    end

    def to_record
      {
        month: month,
        num_comments: num_comments,
        points: points,
        terms: terms
      }
    end

    private

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
