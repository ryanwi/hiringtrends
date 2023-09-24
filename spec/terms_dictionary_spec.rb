# frozen_string_literal: true

describe HiringTrends::TermsDictionary do
  describe "#initalize" do
    it "initializes correctly", vcr: true do
      dictionary = described_class.new("https://gist.githubusercontent.com/ryanwi/6135845/raw/80d82437174965a54186b74ca5bc31ff2f9d4779/software-terms.dic")
    end
  end
end
