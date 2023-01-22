# frozen_string_literal: true

require_relative 'alexandrite_books'
require_relative 'alexandrite_google'
require_relative 'alexandrite_oclc'
require_relative 'error_type/errors'

# Main gem methods for creating books from ISBN
module Alexandrite
  include ErrorType

  # Get and Process data from Google API
  class Google
    extend Alexandrite::GoogleAPI

    attr_reader :result

    def initialize(key, query)
      @result = search_by(key, query)
    end

    # @return [Alexandrite::Book]
    def self.create_book(isbn)
      volume_info = get_volume_info(isbn)

      Alexandrite::Book.new(volume_info)
    end
  end

  # Get and Process data from OCLC API
  class OCLC
    extend Alexandrite::OCLCAPI

    attr_reader :result

    # return [Alexandrite::OCLC]
    def initialize(key, query, api: :oclc)
      @result = search_by(key, query, api: api)
    end

    # @return [Alexandrite::Book]
    def self.create_book(type, identifier)
      query = Alexandrite::OCLC.new(type, identifier)
      response_code = get_response_code(query.result)

      response(response_code, query)
    end
  end

  API = {
    google: Alexandrite::Google,
    oclc: Alexandrite::OCLC
  }.freeze

  def search_by(key, query, api: :google)
    API[api].search_by(key, query)
  end

  def create_book(key, query)
    book = API[:google].create_book(query)
    return API[:oclc].create_book(key, query) if book.error_message

    book
  end

  # @param isbns [Array]
  # @return [Nil]
  def bulk_create(isbns)
    isbns.each do |isbn|
      volume_info = volume_info(isbn)
      book = Alexandrite::Book.new(volume_info)
      add_to_collection(book)
    end
    nil
  end

  private

  def get_volume_info(isbn)
    query = search_by(:isbn, isbn)
    return query[:books].first['volumeInfo'] unless query[:error_message]

    query
  end
end
