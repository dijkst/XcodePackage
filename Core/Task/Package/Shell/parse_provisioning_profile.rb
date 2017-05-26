#!/usr/bin/ruby

require 'open3'
require 'plist'
require 'base64'
require 'digest/sha1'

class ProvisionParser
  def initialize(path, dict)
    @path = path
    @dict = dict
  end

  def path
    @path
  end

  def name
    @dict["Name"]
  end

  def expired?
    DateTime.now > expiration_date
  end

  def expiration_date
    @dict["ExpirationDate"]
  end

  def entitlements
    @dict["Entitlements"]
  end

  def team_id
    entitlements["com.apple.developer.team-identifier"]
  end
  
  def bundle_id
    bundle_id = entitlements["application-identifier"]
    bundle_id[bundle_id.index(".")+1 .. -1]
  end

  def certs
    @dict["DeveloperCertificates"]
  end

  def certs=(certs)
    @dict["DeveloperCertificates"] &= certs
  end
  def to_json(args={})
    @dict.to_json
  end

  def self.parse(path)
    o, e, s = Open3.capture3("openssl smime -inform der -verify -noverify -in \"#{path}\" 2>/dev/null")
    if s.exitstatus != 0
    	raise "Can't extract plist from provision profile\n" + e
    end

    # 将证书字段作为字符串处理
    o.gsub!("<data>", "<string>").gsub!("</data>", "</string>")

    provision_plist = Plist.parse_xml(o)

    # 去除设备列表，减小字符串长度
    provision_plist["ProvisionedDevices"] = provision_plist["ProvisionedDevices"].count if provision_plist["ProvisionedDevices"]

    # 替换证书为 SHA1 列表
    provision_plist['DeveloperCertificates'] = provision_plist['DeveloperCertificates'].map do |object|
    	Digest::SHA1.hexdigest(Base64.decode64(object)).upcase
    end

    self.new(path, provision_plist)
  end
end

if __FILE__ == $0
  require 'json'
  puts ProvisionParser.parse(ARGS[1]).to_json
end
