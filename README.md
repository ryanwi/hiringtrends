# Hacker News (HN) Hiring Trends

A Ruby library for analyizing software technology trends from Hacker News whoishiring posts.
Created by <a href="http://www.ryan-williams.net">Ryan Williams</a>
(<a href="https://twitter.com/ryanwi">@ryanwi</a>)

## Description

## Warnings/Disclaimer

This is a personal development project, in particular for exploring redis.  You are welcome to use, modify, etc. and I welcome any feedback or questions.

## Requirements

  * Ruby (developed and tested on 2.1.1-p76)
  * Redis

## Installation

Install via RubyGems:

    gem install hiringtrends

## Usage

With a command line

    [terminal window 1 - start redis server]
    $ redis-server

    [terminal window 2]
    $ irb

    > require 'hiringtrends'
    > hn = HiringTrends::Program.new
    > hn.get_submissions
    > hn.get_comments_for_submissions
    > hn.analyze_submissions("https://gist.githubusercontent.com/ryanwi/6135845/raw/ca74c2273e3241dc7debbb4e4f45271bb53d9000/software-terms.dic")
    > hn.publish("June", "2014", "Tuesday, "3", 20)


## Author

**Ryan Williams**

- <http://www.ryan-williams.net>
- <https://twitter.com/ryanwi>
- <https://github.com/ryanwi>
