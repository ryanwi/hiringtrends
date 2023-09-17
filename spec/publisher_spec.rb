# frozen_string_literal: true

describe HiringTrends::Publisher do
  describe "#initalize" do
    it "initializes correctly" do
      described_class.new(software_terms: {}, items: [], month: 4, year: 2011, item_id: "2396027")
    end
  end

  describe "#publish" do
    it "publishes" do
      mock_file = instance_double("File")
      allow(mock_file).to receive(:write)
      allow(File).to receive(:open).and_yield(mock_file)

      api_item = {
        "objectID" => "2396027",
        "created_at" => "2011-04-01T13:11:26.000Z",
        "title" => "Ask HN: Who is Hiring? (April 2011)",
        "num_comments" => 295,
        "points" => 280
      }
      items = [HiringTrends::Item.new(api_item)]
      publisher = described_class.new(software_terms: {}, items: items, month: 4, year: 2011, item_id: "2396027")
      publisher.publish
      expect(mock_file).to have_received(:write).twice
    end
  end
end
