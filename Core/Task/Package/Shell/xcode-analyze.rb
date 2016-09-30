#!/usr/bin/env ruby

require 'xcodeproj'
require 'json'

proj = Xcodeproj::Project.open(ARGV[0])
json = proj.pretty_print

frameworks = {}
proj.files.select {|ref|ref.path =~ /\.(framework|a|tbd)$/i}.map {|ref| frameworks[ref.name || File.basename(ref.path)] = ref.path }
json["Frameworks"] = frameworks

puts json.to_json
