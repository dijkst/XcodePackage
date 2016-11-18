
Pod::Spec.new do |s|

  s.name         = "XcodePackage"
  s.version      = "0.0.1"
  s.summary      = "Xcode auto package tool."
  s.description  = <<-DESC
                  Package will build framework and create its podspec.
                   DESC

  s.homepage     = "http://github.com/dijkst/XcodePackage.git"
  s.license      = "MIT"
  s.platform     = :osx, "10.10"
  s.author       = { "Whirlwind" => "whirlwindjames@foxmail.com" }
  s.source       = { :git => "git@github.com:dijkst/XcodePackage.git", :tag => "#{s.version}" }

  s.source_files  = "{Core,ObjCCommandLine,Package}/**/*.{h,m,mm}"
  s.exclude_files = "**/MainMenu.xib"
  s.resources = "Core/Task/Prepare/Script/{RubyEnv,GemEnv}", "Core/**/*.{sh,rb,xcconfig}", "Package/**/*/*.xib", "Package/*.xcassets"
  s.prefix_header_file = "Package/PrefixHeader.pch"
  s.dependency "GCDWebServer"

end
