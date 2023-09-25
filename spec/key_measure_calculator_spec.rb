# frozen_string_literal: true

describe HiringTrends::KeyMeasureCalculator do
  subject { described_class.new(item_collection:) }

  let(:item_collection) { HiringTrends::ItemCollection.new(items:, target_item_id: 37351667) }
  let(:items) do
    today = DateTime.now
    previous_items = Array.new(12) do |i|
      instance_double("HiringTrends::Item", id: 100 - i, created_at: (today << (i + 1)), terms_data: {})
    end
    previous_items.unshift(item)
  end
  let(:item) do
    instance_double("HiringTrends::Item", id: 37351667, created_at: "2023-09-01T15:00:25.000Z", terms_data:)
  end
  let(:terms_data) do
    {
      "AI" => { count: 57, percentage: 18.27, full_term: "AI/alias[AI|Artificial Intelligence]", rank: 8 },
      "React" => { count: 60, percentage: 19.23, full_term: "React/js[react]", rank: 7 }
    }
  end

  describe "#ranked_terms" do
    it "orders the month's results by ranking" do
      expected = {
        "React" => { count: 60, full_term: "React/js[react]", percentage: 19.23, rank: 7 },
        "AI" => { count: 57, full_term: "AI/alias[AI|Artificial Intelligence]", percentage: 18.27, rank: 8 }
      }
      expect(subject.ranked_terms).to eq(expected)
    end
  end

  describe "#top_terms" do
    xit "returns the top terms for the item" do
      tt = subject.top_terms(1)

      expected = {
        "React" => {
          count: 60,
          full_term: "React/js[react]",
          percentage: 19.23,
          rank: 7,
          count_last_month: 1,
          count_last_year: 1,
          rank_change_month: 1,
          rank_last_year: 1,
          rank_change_year: 1
        }
      }
      expect(tt).to eq(expected)
    end
  end

  describe "#top_gainers" do
    xit "returns the top gainers for the item" do
      tg = subject.top_gainers
      expected = [{ count: 1, rank: 1, count_last_month: 1, count_last_year: 1, rank_change_month: 1, rank_last_year: 1, rank_change_year: 1 }]
      expect(tg).to eq(expected)
    end
  end

  describe "#top_losers" do
    xit "returns the top losers for the item" do
      tl = subject.top_losers
      expected = [{ count: 1, rank: 1, count_last_month: 1, count_last_year: 1, rank_change_month: 1, rank_last_year: 1, rank_change_year: 1 }]
      expect(tl).to eq(expected)
    end
  end
end
