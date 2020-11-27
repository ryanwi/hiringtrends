# Hacker News (HN) Hiring Trends

A Ruby library for analyzing software technology trends from Hacker News whoishiring posts.
Created by <a href="https://www.ryanwilliams.dev">Ryan Williams</a>
(<a href="https://twitter.com/ryanwi">@ryanwi</a>)

## Description

## Warnings/Disclaimer

This is a personal development project, in particular for exploring redis.  You are welcome to use, modify, etc. and I welcome any feedback or questions.

## Requirements

  * Ruby (2.5+)
  * Redis

## Installation


## Usage

With a command line

    [terminal window 1 - start redis server]
    $ redis-server

    [terminal window 2]
    $ irb

```ruby
require 'hiringtrends'
hn = HiringTrends::Program.new
hn.get_submissions
hn.get_comments_for_submissions
hn.analyze_submissions("https://gist.githubusercontent.com/ryanwi/6135845/raw/18b427e7f26bfdedf9681df9309d392905213a1e/software-terms.dic")
hn.publish("August", "2017", "Saturday", "12", 20)
```

## Author

**Ryan Williams**

- <https://www.ryanwilliams.dev>
- <https://twitter.com/ryanwi>
- <https://github.com/ryanwi>
