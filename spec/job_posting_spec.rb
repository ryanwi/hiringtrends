# frozen_string_literal: true

describe HiringTrends::JobPosting do
  describe "#has_term" do
    it "finds a basic term" do
      comment = described_class.new("Javascript visual basic web services")
      expect(comment.has_term?("Javascript")).to be true
    end

    it "counts multi-word terms" do
      comment = described_class.new("Javascript visual basic web services")
      expect(comment.has_term?("Visual Basic")).to be true
    end

    it "separates words with slash separators" do
      comment = described_class.new("in this comment is ruby/javascript")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "separates words with comma separators" do
      comment = described_class.new("in this comment is ruby, javascript.")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "separates words with periods at end of sentence" do
      comment = described_class.new("This comment has ruby.")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "is case insensitive" do
      comment = described_class.new("This comment has ruby in it")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "ignore quotes" do
      comment = described_class.new("Javascript  ['angular','backbone','node']")
      expect(comment.has_term?("angular")).to be true
    end

    it "counts Objective-c" do
      comment = described_class.new("Primary languages are javascript and python, with a history in php and a little bit of Objective-c. I have experience with many of the common client-side frameworks like Backbone, Knockout, etc.")
      expect(comment.has_term?("Objective-c")).to be true
    end

    it "counts .NET" do
      comment = described_class.new("this comment has .NET in it")
      expect(comment.has_term?(".NET")).to be true
    end

    it "counts ASP.NET" do
      comment = described_class.new("this comment has ASP.NET in it")
      expect(comment.has_term?("ASP.NET")).to be true
    end

    it "counts term with javascript modifier and dot notation" do
      comment = described_class.new("includes node.js, mongodb")
      expect(comment.has_term?("node.js/js[node]")).to be true
    end

    it "counts term with javascript modifier and no dot" do
      comment = described_class.new("includes NodeJS, mongodb")
      expect(comment.has_term?("node.js/js[node]")).to be true
    end

    it "counts term with javascript modifier and no dot or extension" do
      comment = described_class.new("includes Node, mongodb")
      expect(comment.has_term?("node.js/js[node]")).to be true
    end

    it "counts term with alias modifier using first alias" do
      comment = described_class.new("includes mongo and node")
      expect(comment.has_term?("Mongodb/alias[mongo|mongodb]")).to be true
    end

    it "counts term with alias modifier using 2nd alias" do
      comment = described_class.new("includes mongodb and node")
      expect(comment.has_term?("Mongodb/alias[mongo|mongodb]")).to be true
    end

    it "doesn't count term when it uses alias modifer and none of the aliases are found" do
      comment = described_class.new("includes ruby, rails, postgres")
      expect(comment.has_term?("Mongodb/alias[mongo|mongodb]")).to be false
    end

    context "when term is golang" do
      it "counts capital G Go for golang with trailing comma" do
        comment = described_class.new("Stack: Go, TypeScript, GraphQL, Docker + Kubernetes")
        expect(comment.has_term?("golang")).to be true
      end

      it "counts capital G Go for golang after paren" do
        comment = described_class.new("Apple | Backend (Go, PostgreSQL) engineer | Shanghai, China | ONSITE | Full Time")
        expect(comment.has_term?("golang")).to be true
      end

      it "counts capital G Go for golang on its own" do
        comment = described_class.new("the frontend app is Go in the back and react/redux in the front")
        expect(comment.has_term?("golang")).to be true
      end

      it "counts capital G Go for golang near slash" do
        comment = described_class.new("Nyaruka Ltd - Senior SDE - Go / Python / React / Postgres - REMOTE - $90-$150k")
        expect(comment.has_term?("golang")).to be true
      end

      it "counts capital G Go for golang after slash" do
        comment = described_class.new("We're looking for a C++/Go hacker")
        expect(comment.has_term?("golang")).to be true
      end
    end
  end
end
