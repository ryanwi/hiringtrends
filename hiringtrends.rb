require_relative 'lib/hiringtrends'

hn = HiringTrends::Program.new "https://gist.githubusercontent.com/ryanwi/6135845/raw/9aa9ee8359bc988beabe13ae246cd40a0448fdce/software-terms.dic"
hn.clean
hn.get_submissions
hn.get_comments_for_submissions
hn.save_submissions
hn.analyze_submissions
hn.publish("December", "2020", "Thursday", "31", 20)
