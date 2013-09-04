source 'https://rubygems.org'

gemspec

gem 'rake'

# The development group will no be
# installed on Travis CI.
#
group :development do
  gem 'guard-rspec'

  gem 'pimpmychangelog'

  require 'rbconfig'

  if RbConfig::CONFIG['target_os'] =~ /darwin/i
    if `uname`.strip == 'Darwin' && `sw_vers -productVersion`.strip >= '10.8'
      gem 'terminal-notifier-guard', '~> 1.5.3', require: false
    else
      gem 'growl', require: false
    end rescue Errno::ENOENT

  elsif RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'libnotify', '~> 0.8.0', require: false

  elsif RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i
    gem 'win32console', require: false
    gem 'rb-notifu', '>= 0.0.4', require: false
  end
end

# The test group will be
# installed on Travis CI
#
group :test do
  gem 'rspec'
  gem 'coveralls', require: false
end
