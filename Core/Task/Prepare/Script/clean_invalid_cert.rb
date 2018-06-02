# coding: utf-8
#!/usr/bin/ruby

INVALID=[]
`/usr/bin/security find-identity -p codesigning`.split("\n").each do |line|
  puts line
  match = line.match(/\s+\d+\) (\h+) "(.*)" \((.+)\)$/)
  next if match.nil?
  next if INVALID.include?(match[1])
  INVALID << match
end

puts "\n  Clean invalid identities:"
maxlength = "#{INVALID.length}".length
INVALID.each_with_index do |match, index|
    space_count = maxlength - "#{index+1}".length + 1
    puts "#{" " * space_count}#{index + 1}) #{match[1]} \"#{match[2]}\": #{match[3]}"
    `/usr/bin/security delete-identity -Z #{match[1]} -t`
end
puts " #{" " * maxlength}  #{INVALID.length} invalid identities cleaned up"
