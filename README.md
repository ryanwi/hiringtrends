# Hacker News (HN) Hiring Trends

A Ruby library for analyizing software technology trends from Hacker News whoishiring posts.

## Installation

    gem install hiringtrends

## Usage

With a command line

    $ irb

    > require 'hiringtrends'
    > hn = HiringTrends.new
    > hn.get_submissions
    > hn.get_comments_for_submissions
    > hn.analyze_submissions
