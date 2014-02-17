# Hacker News (HN) Hiring Trends

A Ruby library for analyizing software technology trends from Hacker News whoishiring posts.
Created by <a href="http://www.ryan-williams.net">Ryan Williams</a>
(<a href="https://twitter.com/ryanwi">@ryanwi</a>)

## Description

## Warnings/Disclaimer

This is a personal development project, in particular for exploring redis.  You are welcome to use, modify, etc. and I welcome any feedback or questions.

## Requirements

  * Ruby (developed and tested on 2.0.0-p247)
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
    > hn = HiringTrends.new
    > hn.get_submissions
    > hn.get_comments_for_submissions
    > hn.analyze_submissions("https://gist.github.com/ryanwi/6135845/raw/e0232fa58d3af5c20e38e638e247a7a9b372bdca/software-terms.dic")
    > hn.publish("data.js")


## Author

**Ryan Williams**

- <http://www.ryan-williams.net>
- <https://twitter.com/ryanwi>
- <https://github.com/ryanwi>
