require 'spec_helper'

describe HiringTrends do
  before :each do
    @hn = HiringTrends.new
  end

  # describe "#analyze_submission" do
  #   it "should initialize the terms dictionary from gist" do
  #     @hn.initialize_dictionary
  #   end
  # end

  describe "#analyze_submission" do

    it "separates words with slash separators" do
      terms = {
        "Ruby" => {:count => 0, :percentage => 0},
        "Python" => {:count => 0, :percentage => 0},
        "JavaScript" => {:count => 0, :percentage => 0}
      }
      comments = [
        {"text" => "This first comment has ruby in it."},
        {"text" => "in this comment is ruby/javascript"}
      ]

      terms = @hn.analyze_submission(terms, comments)

      terms["Ruby"][:count].should == 2
      terms["JavaScript"][:count].should == 1
    end

    it "separates words with comma separators" do
      terms = {
        "Ruby" => {:count => 0, :percentage => 0},
        "Python" => {:count => 0, :percentage => 0},
        "JavaScript" => {:count => 0, :percentage => 0}
      }
      comments = [
        {"text" => "This first comment has ruby in it."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms["Ruby"][:count].should == 2
    end

    it "separates words with periods at end of sentence" do
      terms = {"Ruby" => {:count => 0, :percentage => 0}}
      comments = [
        {"text" => "This first comment has ruby."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms["Ruby"][:count].should == 2
    end

    it "is case insensitive" do
      terms = {"Ruby" => {:count => 0, :percentage => 0}}
      comments = [
        {"text" => "This first comment has Ruby in it."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms["Ruby"][:count].should == 2
    end

    it "counts Objective-c" do
      terms = {
        "JavaScript" => {:count => 0, :percentage => 0},
        "Objective-c" => {:count => 0, :percentage => 0},
        "PHP" => {:count => 0, :percentage => 0},
        "Python" => {:count => 0, :percentage => 0}
      }
      comments = [
        {"text" => "Primary languages are javascript and python, with a history in php and a little bit of Objective-c. I have experience with many of the common client-side frameworks like Backbone, Knockout, etc."},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms["Objective-c"][:count].should == 1
    end

    it "ignore quotes" do
      terms = {
        "JavaScript" => {:count => 0, :percentage => 0},
        "angular" => {:count => 0, :percentage => 0},
        "backbone" => {:count => 0, :percentage => 0},
        "node" => {:count => 0, :percentage => 0}
      }
      comments = [
        {"text" => "Javascript  ['angular','backbone','node']"},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms["angular"][:count].should == 1
    end

    it "counts multi-word terms" do
      terms = {
        "Visual Basic" => {:count => 0, :percentage => 0},
        "Web services" => {:count => 0, :percentage => 0},
        "node" => {:count => 0, :percentage => 0}
      }
      comments = [
        {"text" => "Javascript visual basic web services"},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms["Visual Basic"][:count].should == 1
    end

    it "counts .net" do
      terms = {
        ".NET" => {:count => 0, :percentage => 0}
      }
      comments = [
        {"text" => "Javascript visual basic c web services C#/.NET"},
        {"text" => "in this comment is ruby, javascript."}
      ]

      terms = @hn.analyze_submission(terms, comments)
      terms[".NET"][:count].should == 1
    end


  end

end
