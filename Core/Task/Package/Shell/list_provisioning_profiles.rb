# coding: utf-8
#!/usr/bin/ruby

require './parse_provisioning_profile.rb'

PROVISIONS = "#{Dir.home}/Library/MobileDevice/Provisioning\ Profiles/".freeze

def get_profiles
  certs = []
  `/usr/bin/security find-identity -v -p codesigning`.split("\n").each do |line|
  	match = line.match(/\s+\d+\) (\h+) "(.*)"$/)
  	next if match.nil?
  	certs << match[1]
  end

  profiles = {}
  Dir["#{PROVISIONS}*"].each do |p|
  	profile = ProvisionParser.parse(p)
      unless profile.nil?
        profile.certs = certs
        (profiles[profile.team_id] ||= []) << profile
      end
  end
  profiles.each do |team_id, array| 
     array.sort!{ |p1, p2| "#{p1.bundle_id}#{p1.expiration_date}" <=> "#{p2.bundle_id}#{p2.expiration_date}" }.reverse!
  end
  profiles
end

if __FILE__ == $0
  require 'json'
  puts get_profiles.to_json
end
