# frozen_string_literal: true

describe HiringTrends::Publisher do
  describe "#initalize" do
    it "initializes correctly" do
      described_class.new({}, [], "37351667")
    end
  end

  describe "#publish" do
    it "publishes" do
      described_class.new({}, [], "37351667").publish
    end
  end
end
