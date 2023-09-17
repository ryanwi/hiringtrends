# frozen_string_literal: true

require_relative "lib/hiringtrends"

terms = "https://gist.githubusercontent.com/ryanwi/6135845/raw/80d82437174965a54186b74ca5bc31ff2f9d4779/software-terms.dic"
hn = HiringTrends::Program.new terms
hn.fetch_submissions
hn.analyze_submissions
hn.publish(item_id: "37351667")
