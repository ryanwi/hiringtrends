# frozen_string_literal: true

describe HiringTrends::Publisher do
  describe "#initalize" do
    it "initializes correctly" do
      described_class.new(item_collection: nil, key_measure_calculator: nil, dictionary: nil)
    end
  end

  describe "#publish" do
    subject(:publisher) { described_class.new(item_collection:, key_measure_calculator:, dictionary: nil) }

    let(:item) do
      instance_double("HiringTrends::Item", id: 37351667, created_at: "2023-09-01T15:00:25.000Z", terms_data:)
    end
    let(:item_collection) { HiringTrends::ItemCollection.new(items: [item], target_item_id: 37351667) }
    let(:key_measure_calculator) { HiringTrends::KeyMeasureCalculator.new(item_collection:) }
    let(:terms_data) do
      {
        "AI" => { "count" => 57, "percentage" => 18.27, "full_term" => "AI/alias[AI|Artificial Intelligence]",
                  "rank" => 8 },
        "React" => { "count" => 60, "percentage" => 19.23, "full_term" => "React/js[react]", "rank" => 7 }
      }
    end
    let(:mock_file) { instance_double("File") }

    before do
      allow(mock_file).to receive(:write)
      allow(mock_file).to receive(:read)
      allow(File).to receive(:open).and_yield(mock_file)
      allow(item).to receive(:to_record).and_return(
        {
          "month" => "Sep23",
          "num_comments" => 1,
          "points" => 280,
          "terms" => nil
        }
      )
      allow(item_collection).to receive(:last_month_terms_data).and_return(terms_data)
      allow(item_collection).to receive(:last_year_terms_data).and_return(terms_data)
    end

    it "publishes the data file with the right filename" do
      publisher.publish

      expected_filename = "web/data/data-20230901.js"
      expect(File).to have_received(:open).with(expected_filename, "wb")
    end

    it "publishes the data file with the right contents" do
      publisher.publish

      expect(mock_file).to have_received(:write).with("data = ").ordered
      expect(mock_file).to have_received(:write).with(("[\n  {\n    \"month\": \"Sep23\",\n    \"num_comments\": 1,\n    \"points\": 280,\n    \"terms\": null\n  }\n]")).ordered
    end

    it "publishes the post file" do
      publisher.publish

      expected_filename = "web/2023/september.html"
      expect(File).to have_received(:open).with(expected_filename, "w")
    end
  end
end
