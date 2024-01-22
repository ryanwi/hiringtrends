# frozen_string_literal: true

describe HiringTrends::ItemSearch do
  describe "#execute" do
    it "returns the correct result", vcr: true do
      results = described_class.new.execute
      expect(results).to be_a Array
    end
  end
end
