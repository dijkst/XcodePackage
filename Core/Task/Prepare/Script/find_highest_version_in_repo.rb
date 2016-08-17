#!/usr/bin/env ruby

require 'cocoapods-core'

# rsync 仓库
repo = ENV['HOME'] + "/.cocoapods/repos/alibaba-specs"

# git 仓库
repo = ENV['HOME'] +"/.cocoapods/repos/alibaba-inc-specs" unless File.exist?(repo)

source = Pod::Source.new(repo)

puts source.set(ARGV[0]).highest_version.to_s
