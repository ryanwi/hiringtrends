# frozen_string_literal: true

require_relative 'lib/hiringtrends'

terms = "https://gist.githubusercontent.com/ryanwi/6135845/raw/ec4683d6156a1f4158e105c242c72dfaf77320d4/software-terms.dic"
hn = HiringTrends::Program.new terms
hn.clean
hn.get_submissions
hn.get_comments_for_submissions
hn.save_submissions
hn.analyze_submissions
hn.publish("March", "2022", "Sunday", "20")
