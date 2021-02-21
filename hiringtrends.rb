require_relative 'lib/hiringtrends'

hn = HiringTrends::Program.new "https://gist.githubusercontent.com/ryanwi/6135845/raw/1b040e1d1aaad488ed353f09d0b4150dcb123c02/software-terms.dic"
hn.clean
hn.get_submissions
hn.get_comments_for_submissions
hn.save_submissions
hn.analyze_submissions
hn.publish("February", "2021", "Sunday", "21", 20)
