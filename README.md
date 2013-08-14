# Hacker News (HN) Hiring Trends

A Ruby library for analyizing software technology trends from Hacker News whoishiring posts.

## Installation

    gem install hiringtrends


NOTE: redis is required to run this analysis, this assumes redis is already installed and configured

## Usage

With a command line

    [terminal window 1]
    $ redis-server

    [terminal window 2]
    $ irb

    > require 'hiringtrends'
    > hn = HiringTrends.new
    > hn.get_submissions
    > hn.get_comments_for_submissions
    > hn.analyze_submissions
    > hn.publish
