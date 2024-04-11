ruby '~> 2.7'

source 'https://rubygems.org'

gem 'fastlane', '~> 2.217.0'
gem 'fastlane-plugin-sentry', '1.15.0'
gem 'license_finder'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
