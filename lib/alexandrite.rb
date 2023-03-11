# frozen_string_literal: true

require_relative 'alexandrite_book_data'
require_relative 'alexandrite_google'
require_relative 'alexandrite_oclc'
require_relative 'error_type/errors'

# Main gem methods for creating books from ISBN
module Alexandrite
  include ErrorType
  include Alexandrite::BookData

  # Get and Process data from Google API
  class Google
    include Alexandrite
    extend Alexandrite::GoogleAPI

    attr_reader :result

    def initialize(key, query)
      @result = search_with(key, query)
    end

    # @param [String] key
    # @param [String] query
    # @return [nil]
    def self.create_from_google(key, query)
      Alexandrite::BookData.create_data(get_volume_info(key, query))
    rescue StandardError => e
      Alexandrite::BookData.create_data({ :error_message => e.message, 'origin' => 'Google API' })
    end
  end

  # Get and Process data from OCLC API
  class OCLC
    include Alexandrite
    extend Alexandrite::OCLCAPI

    attr_reader :result

    # return [Alexandrite::OCLC]
    def initialize(key, query, api: :oclc)
      @result = search_with(key, query, api: api)
    end

    # @return [Alexandrite::BookData]
    def self.create_from_oclc(type, identifier)
      query = Alexandrite::OCLC.new(type, identifier)
      response_code = get_response_code(query.result)

      response(response_code, query)
    end
  end

  API = {
    google: Alexandrite::Google,
    oclc: Alexandrite::OCLC
  }.freeze

  def search_with(key, query, api: :google)
    API[api].search_by(key, query)
  end

  def create_book(key, query)
    log = Logger.new(STDOUT)
    log.info "Fetching book info from Google API. Key: #{key}. Query: #{query}"
    book = API[:google].create_from_google(key, query)
    if book[:error_message]
      log.warn "Failing when fetching book info. Error message: #{book[:error_message]}"
      log.info "Fetching book info from OCLC API. Key: #{key}. Query: #{query}"
      return API[:oclc].create_from_oclc(key, query)
    end

    book
  end

  # @param key [String]
  # @param data [Array<String>]
  # @return [Array<Alexandrite::BookData>]
  def bulk_create(key, data)
    bookshelf = []
    log = Logger.new(STDOUT)
    data.each do |query|
      book = create_book(key, query)
      log.info "Book created. Key #{key}. Query: #{query}. Source: #{book[:data_source]}"
      bookshelf << book
    end

    bookshelf
  end
end
