# frozen_string_literal: true

require 'vcr'

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'vcr/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {
    erb: true,
    record: :once,
    decode_compressed_response: false,
    match_requests_on: %i[method uri body]
  }
end
