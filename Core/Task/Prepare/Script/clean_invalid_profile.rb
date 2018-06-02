# coding: utf-8
#!/usr/bin/ruby

require './list_provisioning_profiles.rb'

INVALID = []

#COUNT = 0
#def remove(profile, msg)
#  COUNT += 1
#  puts "#{File.basename(profile.path)} \"#{profile.name}\": #{msg}"
##  File.delete(profile.path)
#  true
#end

local_profiles = get_profiles

local_profiles.each do |team_id, profiles|
  valid_bundle_id = []
  profiles.each do |profile|
    if profile.certs.length == 0
      INVALID << [profile, "未发现任何有效证书被安装"]
    elsif profile.expired?
      INVALID << [profile, "已过期"]
    elsif valid_bundle_id.include?(profile.bundle_id)
      INVALID << [profile, "存在更新的版本"]
    else
      valid_bundle_id << profile.bundle_id
    end
  end
end

INVALID.group_by { |profile, msg| msg }.each do |msg, infos|
    puts "#{msg}:"
    infos.each do |profile, msg|
        puts "  #{File.basename(profile.path)} #{profile.name}"
        File.delete(profile.path)
    end
end

puts "扫描无效描述文件完成！已清理 #{INVALID.length} 个。"
