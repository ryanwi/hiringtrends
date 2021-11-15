require_relative 'lib/hiringtrends'

terms = "https://gist.githubusercontent.com/ryanwi/6135845/raw/749910d33a5cf860562048ebd473d6731f9abe6e/software-terms.dic"
hn = HiringTrends::Program.new terms
hn.clean
hn.get_submissions
hn.get_comments_for_submissions
hn.save_submissions
hn.analyze_submissions
hn.publish("November", "2021", "Sunday", "14")
