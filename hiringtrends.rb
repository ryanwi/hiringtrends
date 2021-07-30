require_relative 'lib/hiringtrends'

hn = HiringTrends::Program.new "https://gist.githubusercontent.com/ryanwi/6135845/raw/9c13f1e036b8f18554fccd4755c1cc3aeac00453/software-terms.dic"
hn.clean
hn.get_submissions
hn.get_comments_for_submissions
hn.save_submissions
hn.analyze_submissions
hn.publish("February", "2021", "Sunday", "21", 20)
