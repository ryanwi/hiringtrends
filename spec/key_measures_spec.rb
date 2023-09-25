# frozen_string_literal: true

describe HiringTrends::KeyMeasures do
  describe "#initalize" do
  end
end

# let(:item) { instance_double("HiringTrends::Item", id: 37351667, created_at: "2023-09-01T15:00:25.000Z", terms_data:) }
# let(:last_month_item) { instance_double("HiringTrends::Item", id: 36956867, created_at: "2023-08-01T15:02:08.000Z", terms_data: last_month_terms_data) }
# let(:items) { [item] }
# let(:terms_data) do
#   {
#     "AI" => { count: 57, percentage: 18.27, full_term: "AI/alias[AI|Artificial Intelligence]", rank: 8 },
#     "React" => { count: 60, percentage: 19.23, full_term: "React/js[react]", rank: 7 }
#   }
# end
# let(:last_month_terms_data) do
#   {
#     "AI" => { count: 53, percentage: 14.76, full_term: "AI/alias[AI|Artificial Intelligence]", rank: 9 },
#     "React" => { count: 60, percentage: 19.23, full_term: "React/js[react]", rank: 7 }
#   }
# end
# let(:mock_file) { instance_double("File") }

# before do
#   allow(mock_file).to receive(:write)
#   allow(mock_file).to receive(:read)
#   allow(File).to receive(:open).and_yield(mock_file)
#   # allow(last_month_item).to receive(:to_record)
#   allow(item).to receive(:to_record).and_return({
#     month: "Sep23",
#     num_comments: 1,
#     points: 280,
#     terms: nil
#   })
# end
