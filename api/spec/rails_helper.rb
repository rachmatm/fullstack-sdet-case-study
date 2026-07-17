# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['SECRET_KEY_BASE'] ||= 'test-secret-key'

require 'spec_helper'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Request specs default to www.example.com, which this API blocks via
  # Host Authorization in test. Use a local host so requests exercise the
  # controller behavior instead of failing at the rack boundary.
  config.before(:each, type: :request) do
    host! 'localhost'
  end
end
