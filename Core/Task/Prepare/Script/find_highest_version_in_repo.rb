#!/usr/bin/env ruby

require 'cocoapods-core'

repos = ENV['HOME'] +"/.cocoapods/repos/*"
Dir[repos].each do |repo|
    source = Pod::Source.new(repo)
    version = source.set(ARGV[0]).highest_version
    unless version.nil?
        puts version.to_s
        break
    end
end
