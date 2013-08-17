# Hacker News (HN) Hiring Trends

A Ruby library for analyizing software technology trends from Hacker News whoishiring posts.

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
    > hn = HiringTrends.new("https://gist.github.com/ryanwi/6135845/raw/106aa752a61456cfd18c70f1810d61690dea2eb1/software-terms.dic")
    > hn.get_submissions
    > hn.get_comments_for_submissions
    > hn.analyze_submissions
    > hn.publish
