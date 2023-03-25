# frozen_string_literal: true

require_relative 'lib/hiringtrends'

terms = "https://gist.githubusercontent.com/ryanwi/6135845/raw/da40c9790227757fcc4f63a84be56e54215813a7/software-terms.dic"
hn = HiringTrends::Program.new terms
hn.clean
hn.get_submissions
hn.get_comments_for_submissions;nil
hn.save_submissions;nil
hn.analyze_submissions;nil
hn.publish("March", "2023", "Saturday", "20")
