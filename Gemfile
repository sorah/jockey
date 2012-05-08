source "http://rubygems.org"

group :test do
  gem "rspec"
  gem "guard-rspec"
  case RUBY_PLATFORM
  when /darwin/i
    gem "rb-fsevent"
  when /linux/i
    gem "rb-inotify"
  end
end

group :development do
  gem 'shotgun'
end

gem "rb-appscript"

gem "sinatra"
gem "thin"

gem "sprockets"

gem "haml"
gem "sass"
gem "coffee-script"
