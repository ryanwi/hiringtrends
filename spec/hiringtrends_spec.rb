require_relative './spec_helper'

describe HiringTrends do
  before :each do
    @hn = HiringTrends.new
  end

  describe "#analyze_submission" do
    it "should initialize the terms dictionary from gist" do
      @hn.initialize_dictionary
    end
  end


  describe "#analyze_submission" do

    it "separates words with slash separators" do
      terms = {
        "Ruby" => {:count => 0, :percentage => 0}, 
        "Python" => {:count => 0, :percentage => 0}, 
        "JavaScript" => {:count => 0, :percentage => 0}
      }
      comments = [{"item" => {"text" => "This first comment has ruby in it."}}, 
        {"item" => {"text" => "in this comment is ruby/javascript"}}]

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
      comments = [{"item" => {"text" => "This first comment has ruby in it."}}, 
        {"item" => {"text" => "in this comment is ruby, javascript."}}]

      terms = @hn.analyze_submission(terms, comments)
      terms["Ruby"][:count].should == 2
    end

    it "separates words with periods at end of sentence" do
      terms = {"Ruby" => {:count => 0, :percentage => 0}}
      comments = [{"item" => {"text" => "This first comment has ruby."}}, 
        {"item" => {"text" => "in this comment is ruby, javascript."}}]

      terms = @hn.analyze_submission(terms, comments)
      terms["Ruby"][:count].should == 2
    end

    it "is case insensitive" do
      terms = {"Ruby" => {:count => 0, :percentage => 0}}
      comments = [{"item" => {"text" => "This first comment has Ruby in it."}}, 
        {"item" => {"text" => "in this comment is ruby, javascript."}}]

      terms = @hn.analyze_submission(terms, comments)
      terms["Ruby"][:count].should == 2
    end
  end

end