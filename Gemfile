source 'https://rubygems.org' do
  gem 'rake'
  gem 'cocoapods', '1.7.0'
  gem 'xcpretty-travis-formatter'
  gem 'octokit', "~> 4.0"
  gem 'fastlane', "2.103.1"
  gem 'dotenv'
  gem 'rubyzip', "~> 1.2.2"
end

plugins_path = File.join(File.dirname(__FILE__), 'Scripts/fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
