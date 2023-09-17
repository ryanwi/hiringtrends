# frozen_string_literal: true

require_relative "lib/hiringtrends"

terms_url = "https://gist.githubusercontent.com/ryanwi/6135845/raw/80d82437174965a54186b74ca5bc31ff2f9d4779/software-terms.dic"

hn = HiringTrends::Program.new(dictionary_url: terms_url, month: 9, year: 2023, item_id: "37351667")
hn.fetch_all_submissions
# hn.fetch_submission
hn.analyze_submissions
hn.publish
