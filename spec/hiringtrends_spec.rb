# frozen_string_literal: true

describe HiringTrends::Program, vcr: true do
  subject { described_class.new(dictionary_url: "https://gist.githubusercontent.com/ryanwi/6135845/raw/80d82437174965a54186b74ca5bc31ff2f9d4779/software-terms.dic", item_id: 2396027) }

  describe "#initialize" do
    it "creates the terms hash structure" do
      expect(subject.dictionary.software_terms).to be_a(Hash)
    end

    it "key is the term" do
      expect(subject.dictionary.software_terms.keys.first).to eq(".NET")
    end

    it "term value is a hash" do
      expect(subject.dictionary.software_terms.values.first).to eq({ count: 0, full_term: ".NET", mavg3: 0, percentage: 0 })
    end
  end

  describe "#fetch_submission" do
    it "succeeds", vcr: true do
      subject.fetch_submission
    end
  end
end
