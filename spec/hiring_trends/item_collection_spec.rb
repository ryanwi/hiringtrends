# frozen_string_literal: true

describe HiringTrends::ItemCollection do
  describe "#initalize" do
    it "initializes correctly" do
      expect(described_class.new(items: [], target_item_id: nil).count).to eq(0)
    end
  end
end
