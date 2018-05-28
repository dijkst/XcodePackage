# coding: utf-8
#!/usr/bin/ruby

INVALID=[]
`/usr/bin/security find-identity -p codesigning`.split("\n").each do |line|
  puts line
  match = line.match(/\s+\d+\) (\h+) "(.*)" \((.+)\)$/)
  next if match.nil?
  next if INVALID.include?(match[1])
#  `/usr/bin/security delete-identity -Z #{match[1]} -t`
  puts "#{match[1]} \"#{match[2]}\": #{match[3]}"
  INVALID << match[1]
end

puts "扫描无效代码签名证书完成！已清理 #{INVALID.length} 个。"
