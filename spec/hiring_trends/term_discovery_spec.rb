# frozen_string_literal: true

describe HiringTrends::TermDiscovery do
  describe "Parser.clean_text" do
    it "turns paragraphs into lines and decodes entities" do
      expect(HiringTrends::TermDiscovery::Parser.clean_text("Acme | Remote<p>Python &amp; Go")).to eq("Acme | Remote\nPython & Go")
    end
  end

  describe "Parser.resume?" do
    it "flags candidate résumé posts" do
      expect(HiringTrends::TermDiscovery::Parser.resume?("Location: Spain\nRemote: Yes\nRésumé/CV: https://example.com")).to be true
    end

    it "does not flag job postings" do
      expect(HiringTrends::TermDiscovery::Parser.resume?("Acme | Engineer | REMOTE\nWe build things.")).to be false
    end
  end

  describe "Parser.stack_items" do
    it "splits a stack line into items" do
      text = "Acme | Engineer\nStack: TypeScript/Node.js, Postgres (RDS), Claude Code and Temporal."
      expect(HiringTrends::TermDiscovery::Parser.stack_items(text)).to eq(["TypeScript", "Node.js", "Postgres", "Claude Code", "Temporal"])
    end

    it "keeps acronym pairs together" do
      expect(HiringTrends::TermDiscovery::Parser.stack_items("Tech stack: CI/CD, Terraform")).to eq(["CI/CD", "Terraform"])
    end

    it "drops urls and lowercase descriptive phrases" do
      expect(HiringTrends::TermDiscovery::Parser.stack_items("We use: https://example.com/x, workflow orchestration, Ray")).to eq(["Ray"])
    end

    it "ignores lines that are not stack lines" do
      expect(HiringTrends::TermDiscovery::Parser.stack_items("Acme | Engineer\nWe love Python")).to be_empty
    end
  end

  describe "Parser.capitalized_phrases" do
    it "finds capitalized words and pairs, skipping the header line" do
      phrases = HiringTrends::TermDiscovery::Parser.capitalized_phrases("Acme Corp | Remote\nwe use Claude Code daily")
      expect(phrases).to include("Claude", "Code", "Claude Code")
      expect(phrases).not_to include("Acme")
    end
  end

  describe "Parser.known_spellings" do
    it "includes names, aliases and js variations" do
      known = HiringTrends::TermDiscovery::Parser.known_spellings(["Next.js/alias[NextJS]", "React/js[react]", "golang"])
      expect(known).to include("next.js", "nextjs", "react", "react.js", "reactjs", "golang", "go")
    end
  end

  describe "#from_stack_lines" do
    subject(:discovery) { described_class.new(recent_items:, prior_items:, raw_terms: ["Python"]) }

    let(:recent_items) do
      comments = %w[Alpha Beta Gamma Delta].map do |company|
        { "text" => "#{company} | Engineer<p>Stack: Python, Temporal, Zed" }
      end
      [instance_double(HiringTrends::Item, comments:)]
    end
    let(:prior_items) do
      [instance_double(HiringTrends::Item, comments: [{ "text" => "Omega | Engineer<p>Stack: Temporal" }])]
    end

    it "returns unknown terms named by enough companies, with counts for both windows" do
      temporal = discovery.from_stack_lines(min_postings: 1).find { |c| c.term == "Temporal" }
      expect([temporal.recent, temporal.prior, temporal.stack_companies]).to eq([4, 1, 4])
    end

    it "excludes terms already in the dictionary" do
      expect(discovery.from_stack_lines(min_postings: 1).map(&:term)).not_to include("Python")
    end
  end

  describe HiringTrends::TermDiscovery::Candidate do
    it "computes growth from unrounded rates" do
      candidate = described_class.new(term: "X", recent: 10, prior: 1, recent_total: 1000, prior_total: 4000,
                                      stack_companies: 0)
      expect(candidate.change).to eq(3900)
      expect(candidate.prior_share).to eq(0.0)
    end

    it "has no growth when the term is new" do
      expect(described_class.new(term: "X", recent: 3, prior: 0, recent_total: 10, prior_total: 10).change).to be_nil
    end
  end
end
