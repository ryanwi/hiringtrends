require 'spec_helper'

describe HiringTrends::JobPosting do
  it "initializes" do
    tc = HiringTrends::JobPosting.new("comment")
  end

  describe "#has_term" do
    it "finds a basic term" do
      comment = HiringTrends::JobPosting.new("Javascript visual basic web services")
      counted = comment.has_term? "Javascript"
      counted.should be_true
    end

    it "counts multi-word terms" do
      comment = HiringTrends::JobPosting.new("Javascript visual basic web services")
      counted = comment.has_term? "Visual Basic"
      counted.should be_true
    end

    it "separates words with slash separators" do
      comment = HiringTrends::JobPosting.new("in this comment is ruby/javascript")
      counted = comment.has_term? "Ruby"
      counted.should be_true
    end

    it "separates words with comma separators" do
      comment = HiringTrends::JobPosting.new("in this comment is ruby, javascript.")
      counted = comment.has_term? "Ruby"
      counted.should be_true
    end

    it "separates words with periods at end of sentence" do
      comment = HiringTrends::JobPosting.new("This comment has ruby.")
      counted = comment.has_term? "Ruby"
      counted.should be_true
    end

    it "is case insensitive" do
      comment = HiringTrends::JobPosting.new("This comment has ruby in it")
      counted = comment.has_term? "Ruby"
      counted.should be_true
    end

    it "ignore quotes" do
      comment = HiringTrends::JobPosting.new("Javascript  ['angular','backbone','node']")
      counted = comment.has_term? "angular"
      counted.should be_true
    end

    it "counts Objective-c" do
      comment = HiringTrends::JobPosting.new("Primary languages are javascript and python, with a history in php and a little bit of Objective-c. I have experience with many of the common client-side frameworks like Backbone, Knockout, etc.")
      counted = comment.has_term? "Objective-c"
      counted.should be_true
    end

    it "counts .NET" do
      comment = HiringTrends::JobPosting.new("this comment has .NET in it")
      counted = comment.has_term? ".NET"
      counted.should be_true
    end

    it "counts ASP.NET" do
      comment = HiringTrends::JobPosting.new("this comment has ASP.NET in it")
      counted = comment.has_term? "ASP.NET"
      counted.should be_true
    end

    it "counts term with javascript modifier and dot notation" do
      comment = HiringTrends::JobPosting.new("includes node.js, mongodb")
      counted = comment.has_term? "node.js/js[node]"
      counted.should be_true
    end

    it "counts term with javascript modifier and no dot" do
      comment = HiringTrends::JobPosting.new("includes NodeJS, mongodb")
      counted = comment.has_term? "node.js/js[node]"
      counted.should be_true
    end

    it "counts term with javascript modifier and no dot or extension" do
      comment = HiringTrends::JobPosting.new("includes Node, mongodb")
      counted = comment.has_term? "node.js/js[node]"
      counted.should be_true
    end

    it "counts term with alias modifier using first alias" do
      comment = HiringTrends::JobPosting.new("includes mongo and node")
      counted = comment.has_term? "Mongodb/alias[mongo|mongodb]"
      counted.should be_true
    end

    it "counts term with alias modifier using 2nd alias" do
      comment = HiringTrends::JobPosting.new("includes mongodb and node")
      counted = comment.has_term? "Mongodb/alias[mongo|mongodb]"
      counted.should be_true
    end

    it "doesn't count term when it uses alias modifer and none of the aliases are found" do
      comment = HiringTrends::JobPosting.new("includes ruby, rails, postgres")
      counted = comment.has_term? "Mongodb/alias[mongo|mongodb]"
      counted.should be_false
    end

  end

end
