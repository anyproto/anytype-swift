ruby '2.7.2'

source 'https://rubygems.org'

gem 'fastlane', '~> 2.229.0'
gem 'fastlane-plugin-sentry', '1.15.0'
gem 'license_finder'
# https://github.com/CocoaPods/Xcodeproj/pull/942
# branch - "feature/Xcode-16.0-Support"
gem 'xcodeproj', git: "https://github.com/Brett-Best/Xcodeproj", ref: "2b87c2c" 

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
