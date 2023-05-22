# frozen_string_literal: true

require_relative 'lib/hiringtrends'

terms = "https://gist.githubusercontent.com/ryanwi/6135845/raw/5c3d3362acf0391304e98a363ab53c0fb93fe41a/software-terms.dic"
hn = HiringTrends::Program.new terms
hn.clean
hn.get_submissions
hn.get_comments_for_submissions;nil
hn.save_submissions;nil
hn.analyze_submissions;nil
hn.publish("May", "2023", "Sunday", "21")
