#!/usr/bin/env ruby

require 'xcodeproj'
require 'json'

scheme = Xcodeproj::XCScheme.new(ARGV[0])

targets = {}
prefix = "container:"
scheme.build_action.entries.select { |entry| entry.build_for_archiving? }.map {|entry| entry.buildable_references[0]}.each do |r|
    path = r.target_referenced_container
    path = path[prefix.length..-1] if path.start_with?(prefix)
    targets[r.target_name] = path
end

puts targets.to_json
