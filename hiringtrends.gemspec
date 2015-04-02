Gem::Specification.new do |s|
  s.name = 'hiringtrends'
  s.version = '0.5.0'
  s.date = '2015-04-02'
  s.summary = 'Hacker News Hiring Trends'
  s.description = 'Most popular programming languagues and technologies from Hacker News monthly whoishiring posts'
  s.authors = ["Ryan Williams"]
  s.email = 'ryan@ryan-williams.net'
  s.homepage = 'https://github.com/ryanwi/hiringtrends'
  s.files = ["lib/hiringtrends.rb", "lib/hiringtrends/program.rb", "lib/hiringtrends/job_posting.rb"]
  s.require_paths = ["lib"]
  s.license = 'MIT'
  s.add_dependency('faraday')
  s.add_dependency('redis')
  s.add_dependency('liquid')
  s.add_development_dependency('rspec')
  s.requirements << 'redis'
end
