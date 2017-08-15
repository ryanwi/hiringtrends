require 'spec_helper'

describe HiringTrends::JobPosting do
  it "initializes" do
    tc = HiringTrends::JobPosting.new("comment")
  end

  describe "#has_term" do
    it "finds a basic term" do
      comment = HiringTrends::JobPosting.new("Javascript visual basic web services")
      expect(comment.has_term?("Javascript")).to be true
    end

    it "counts multi-word terms" do
      comment = HiringTrends::JobPosting.new("Javascript visual basic web services")
      expect(comment.has_term?("Visual Basic")).to be true
    end

    it "separates words with slash separators" do
      comment = HiringTrends::JobPosting.new("in this comment is ruby/javascript")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "separates words with comma separators" do
      comment = HiringTrends::JobPosting.new("in this comment is ruby, javascript.")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "separates words with periods at end of sentence" do
      comment = HiringTrends::JobPosting.new("This comment has ruby.")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "is case insensitive" do
      comment = HiringTrends::JobPosting.new("This comment has ruby in it")
      expect(comment.has_term?("Ruby")).to be true
    end

    it "ignore quotes" do
      comment = HiringTrends::JobPosting.new("Javascript  ['angular','backbone','node']")
      expect(comment.has_term?("angular")).to be true
    end

    it "counts Objective-c" do
      comment = HiringTrends::JobPosting.new("Primary languages are javascript and python, with a history in php and a little bit of Objective-c. I have experience with many of the common client-side frameworks like Backbone, Knockout, etc.")
      expect(comment.has_term?("Objective-c")).to be true
    end

    it "counts .NET" do
      comment = HiringTrends::JobPosting.new("this comment has .NET in it")
      expect(comment.has_term?(".NET")).to be true
    end

    it "counts ASP.NET" do
      comment = HiringTrends::JobPosting.new("this comment has ASP.NET in it")
      expect(comment.has_term?("ASP.NET")).to be true
    end

    it "counts term with javascript modifier and dot notation" do
      comment = HiringTrends::JobPosting.new("includes node.js, mongodb")
      expect(comment.has_term?("node.js/js[node]")).to be true
    end

    it "counts term with javascript modifier and no dot" do
      comment = HiringTrends::JobPosting.new("includes NodeJS, mongodb")
      expect(comment.has_term?("node.js/js[node]")).to be true
    end

    it "counts term with javascript modifier and no dot or extension" do
      comment = HiringTrends::JobPosting.new("includes Node, mongodb")
      expect(comment.has_term?("node.js/js[node]")).to be true
    end

    it "counts term with alias modifier using first alias" do
      comment = HiringTrends::JobPosting.new("includes mongo and node")
      expect(comment.has_term?("Mongodb/alias[mongo|mongodb]")).to be true
    end

    it "counts term with alias modifier using 2nd alias" do
      comment = HiringTrends::JobPosting.new("includes mongodb and node")
      expect(comment.has_term?("Mongodb/alias[mongo|mongodb]")).to be true
    end

    it "doesn't count term when it uses alias modifer and none of the aliases are found" do
      comment = HiringTrends::JobPosting.new("includes ruby, rails, postgres")
      expect(comment.has_term?("Mongodb/alias[mongo|mongodb]")).to be false
    end

  end

end
