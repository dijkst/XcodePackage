#!/usr/bin/ruby
require 'pathname'
selected_scheme_path= '/Users/Whirlwind/Documents/Developer/TestPackage/TestPackage.xcodeproj/xcshareddata/xcschemes/TestPackage.xcscheme'
selected_project_path = '/Users/Whirlwind/Documents/Developer/TestPackage/TestPackage.xcodeproj'
selected_scheme_container = Pathname.new(selected_project_path).dirname.to_s
#selected_scheme_container = '/Users/Whirlwind/Documents/Developer/XcodePackage'
#selected_scheme_path = '/Users/Whirlwind/Documents/Developer/XcodePackage/Package.xcworkspace/xcuserdata/whirlwind.xcuserdatad/xcschemes/Package1.xcscheme'

require 'xcodeproj'
require 'fileutils'

prefix = "container:"

selected_scheme = Xcodeproj::XCScheme.new(selected_scheme_path)

puts selected_scheme.build_action.entries

selected_target_references = selected_scheme.build_action.entries.map {|entry| entry.buildable_references}.flatten

selected_scheme_content = {}
selected_target_references.each do |ref|
	selected_scheme_content[ref.target_name] = ref.target_referenced_container[prefix.length..-1]
end

projects = {}
selected_scheme_content.values.uniq.each do |project_path|
	path = File.join(selected_scheme_container, project_path)
	projects[project_path] = Xcodeproj::Project.open(path)
end


TARGETS = {}

def add_target(target)
	platform = target.common_resolved_build_setting("SUPPORTED_PLATFORMS") || target.sdk
	sdks = []
	sdks << "ios" if platform.index 'iphoneos'
	sdks << "osx" if platform.index 'macosx'
	sdks << "tvos" if platform.index 'appletvos'
	sdks << "watchos" if platform.index 'watchos'
	
	type = target.common_resolved_build_setting("MACH_O_TYPE")
	if type.nil?
		type = case target.symbol_type
		when :framework
			"mh_dylib"
		when :dynamic_library
			"mh_dylib"
		when :static_library
			"staticlib"
		when :bundle
			"mh_bundle"
		else 
			"mh_execute"
		end
	end
	
	TARGETS[target] = {:sdk => sdks, :type => type}
end

selected_scheme_content.each do |target_name, project_path|
	project = projects[project_path]
	target = project.targets.find {|t| t.name == target_name}
	puts "--------"
	puts target.name
	puts "resources:", target.resources_build_phase.file_display_names.inspect
#	add_target(target)
end

user_data_dir = Xcodeproj::XCScheme.user_data_dir(selected_project_path, "XcodePackage")
FileUtils.rm_rf(user_data_dir)

#ENV['USER'] = 'XcodePackage'
#
#schemes = {}
#TARGETS.each do |target, value|
#	type = value[:type]
#	value[:sdk].each do |sdk|
#		scheme_name = "#{sdk}-#{type}"
#		scheme = schemes[scheme_name] ||= Xcodeproj::XCScheme.new()
#		scheme.add_build_target(target, false)
#	end
#end
#schemes.each do |name, scheme|
#	scheme.save_as(selected_project_path, name, false)
#end
