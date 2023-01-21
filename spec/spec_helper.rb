# frozen_string_literal: true
# frozen_string_literal: tru

require 'rspec'
require 'net/http'
require 'json'
require 'factory_bot'
require 'vcr'
require 'pry-byebug'
require 'helpers/format'
require 'support/vcr_setup'
require 'alexandrite'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
