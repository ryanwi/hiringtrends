# frozen_string_literal: true

module HiringTrends
  # Represents an individual hn item with associated details.
  class Item
    # Define accessors to delegate to the underlying item JSON/hash data
    # item schema described https://hn.algolia.com/api
    %w[id title author created_at points children].each do |key|
      define_method(key) { values[key] }
    end

    attr_reader :values, :terms_data

    def initialize(values = {})
      @values = values
      @terms_data = {}
    end

    def self.load(item_id:, force_api_source: false)
      filename = "data/item_#{item_id}.json"
      if File.exist?(filename) && !force_api_source
        contents = JSON.parse(File.read(filename))
        new(contents)
      else
        conn = Faraday.new(url: HN_API_BASE_URL) do |builder|
          builder.response :json
        end
        response = conn.get "/api/v1/items/#{item_id}"
        item = new(response.body)
        item.save
        item
      end
    end

    def comments
      @comments ||= values["children"].reject { |comment| comment["text"].nil? } || []
    end

    def rel
      "/api/v1/items/#{id}"
    end

    def month
      match = /ask hn: who is hiring\? \((?<month>.*) (?<year>\d{4})\)/i.match(title)
      "#{match[:month][0...3]}#{match[:year][2..4]}"
    end

    def save
      File.open("data/item_#{id}.json", "wb") do |f|
        f.write(values.to_json)
      end
    end

    def analyze(terms_dictionary)
      HiringTrends.logger.info "Analyzing #{id}: #{title}"

      @terms_data = terms_dictionary.term_counts_template

      count_terms_in_comments
      calculate_percentage_for_terms
      rank_terms_by_count
    end

    def to_record
      {
        "month" => month,
        "num_comments" => comments.count,
        "points" => points,
        "terms" => terms_data.transform_values do |term_data|
          term_data.slice("count", "percentage", "full_term", "rank")
        end
      }
    end

    private

    attr_writer :values, :terms_data

    # accumulate mentions of term as comments are searched
    def count_terms_in_comments
      comments.each do |comment|
        posting = HiringTrends::JobPosting.new(job_description: comment["text"])

        # identify if each term is in the comment/job description
        terms_data.each_key do |term|
          # increment count as its found
          terms_data[term]["count"] += 1 if posting.term?(terms_data[term]["full_term"])
        end
      end
    end

    def calculate_percentage_for_terms
      terms_data.each_key do |term|
        terms_data[term]["percentage"] = ((terms_data[term]["count"] / comments.count.to_f) * 100).round(2)
      end
    end

    def rank_terms_by_count
      ranked_terms = terms_data.sort_by { |_k, v| -v["count"] }.to_a
      ranked_terms.each_with_index { |item, index| terms_data[item[0]]["rank"] = index + 1 }
    end
  end
end
