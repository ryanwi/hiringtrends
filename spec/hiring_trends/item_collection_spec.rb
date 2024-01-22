# frozen_string_literal: true

describe HiringTrends::ItemCollection do
  describe "#initalize" do
    it "initializes correctly" do
      described_class.new(items: [], target_item_id: nil)
    end
  end
end
