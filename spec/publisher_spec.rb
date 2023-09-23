# frozen_string_literal: true

describe HiringTrends::Publisher do
  describe "#initalize" do
    it "initializes correctly" do
      described_class.new(software_terms: {}, items: [], item_id: 2396027)
    end
  end

  describe "#publish" do
    let(:api_item) {
      {
        "id" => 2396027,
        "created_at" => "2011-04-01T13:11:26.000Z",
        "title" => "Ask HN: Who is Hiring? (April 2011)",
        "points" => 280,
        "children" => [{ "id" => 2404566, "created_at" => "2011-04-03T23:43:58.000Z" }]
      }
    }
    let(:items) { [HiringTrends::Item.new(api_item)] }

    it "publishes the data file with the right filename" do
      mock_file = instance_double("File")
      allow(mock_file).to receive(:write)
      allow(File).to receive(:open).and_yield(mock_file)
      expected_filename = "web/data/data-20110401.js"

      publisher = described_class.new(software_terms: {}, items:, item_id: 2396027)
      publisher.publish

      expect(File).to have_received(:open).with(expected_filename, "wb")
    end

    it "publishes the data file with the right contents" do
      mock_file = instance_double("File")
      allow(mock_file).to receive(:write)
      allow(File).to receive(:open).and_yield(mock_file)

      publisher = described_class.new(software_terms: {}, items:, item_id: 2396027)
      publisher.publish

      expect(mock_file).to have_received(:write).with("data = ").ordered
      expect(mock_file).to have_received(:write).with(("[\n  {\n    \"month\": \"Apr11\",\n    \"num_comments\": 1,\n    \"points\": 280,\n    \"terms\": null\n  }\n]")).ordered
    end
  end
end
