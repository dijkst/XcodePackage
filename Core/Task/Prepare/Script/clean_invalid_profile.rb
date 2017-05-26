# coding: utf-8
#!/usr/bin/ruby

require './list_provisioning_profiles.rb'

count = 0
def remove(profile, msg)
  count += 1
  puts "#{File.basename(profile.path)} \"#{profile.name}\": #{msg}"
  File.delete(profile.path)
  true
end

local_profiles = get_profiles

local_profiles.each do |team_id, profiles|
  valid_bundle_id = []
  profiles.delete_if do |profile|
    if profile.certs.length == 0
      remove(profile, "该 Profile 未发现任何有效证书被安装。")
    elsif profile.expired?
      remove(profile, "该 Profile 已过期。")
    elsif valid_bundle_id.include?(profile.bundle_id)
      remove(profile, "该 Profile 过旧，存在更新的版本。")
    else
      valid_bundle_id << profile.bundle_id
      false
    end
  end
end

puts "扫描无效描述文件完成！已清理 #{count} 个。"

local_profiles
