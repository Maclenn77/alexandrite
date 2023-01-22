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

    # @return [Alexandrite::BookData]
    def self.create_from_google(key, query)
      Alexandrite::BookData.create_data(get_volume_info(key, query))
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
    book = API[:google].create_from_google(key, query)
    return API[:oclc].create_from_oclc(key, query) if book[:error_message]

    book
  end

  # @param key [String]
  # @param data [Array<String>]
  # @return [Array<Alexandrite::BookData]
  def bulk_create(key, data)
    bookshelf = []
    data.each do |query|
      book = create_book(key, query)
      bookshelf << book
    end

    bookshelf
  end
end
