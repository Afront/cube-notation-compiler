# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in cunoco.gemspec
gemspec

gem "rake", "~> 13.0"
gem "minitest", "~> 5.0"
gem "rubocop", "~> 0.80"

group :test, :optional => true do
	gem "rbs", :group => :test
	gem 'stackprof', :group => :test
end
