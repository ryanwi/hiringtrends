# frozen_string_literal: true

describe HiringTrends::TermsDictionary do
  describe "#initalize" do
    it "initializes correctly", :vcr do
      dictionary = described_class.new("https://gist.githubusercontent.com/ryanwi/6135845/raw/80d82437174965a54186b74ca5bc31ff2f9d4779/software-terms.dic")
      expect(dictionary.raw_terms).not_to be_empty
    end
  end

  describe "config/terms.dic" do
    subject(:dictionary) { described_class.new(File.expand_path("../../config/terms.dic", __dir__)) }

    let(:names) { dictionary.raw_terms.map { |term| term.split("/").first } }

    it "loads terms from the local file" do
      expect(dictionary.raw_terms).not_to be_empty
    end

    it "has no duplicate term names" do
      duplicates = names.tally.select { |_, count| count > 1 }.keys
      expect(duplicates).to be_empty
    end

    it "only uses known modifiers" do
      invalid = dictionary.raw_terms.reject do |term|
        modifier = described_class.parse_modifier(term)
        modifier.nil? || modifier.match?(/\A(js|alias)\[[^\[\]]+\]\z/)
      end
      expect(invalid).to be_empty
    end

    it "has no surrounding whitespace in terms" do
      expect(dictionary.raw_terms.reject { |term| term == term.strip }).to be_empty
    end
  end
end
