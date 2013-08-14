require_relative './spec_helper'

describe HiringTrends do
  it "should initialize the terms dictionary from gist" do
  	hn = HiringTrends.new
  	hn.initialize_dictionary
  	fail
  end
end