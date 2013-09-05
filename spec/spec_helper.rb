require 'rubygems'
require 'coveralls'
Coveralls.wear!

require 'http_content_type'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  config.order = :random
  config.filter_run focus: ENV['CI'] != 'true'
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
end
