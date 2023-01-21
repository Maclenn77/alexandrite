# frozen_string_literal: true

# require all files
require_relative 'alexandrite/version'
require 'rubygems'
require 'faraday'
require 'faraday/decode_xml'
require 'json'
require_relative 'helpers/format'
require_relative 'helpers/validation'
require 'pry'
require 'nokogiri'

module Alexandrite
  # Consume OCLC API
  module OCLCAPI
    include Nokogiri
    include Alexandrite::Helpers::Format
    include Alexandrite::Helpers::Validation

    BASE_URL = 'http://classify.oclc.org/classify2/Classify?'

    # @param query [String]
    # @return [Faraday::Response]
    def search_by(key, query, summary: true)
      search = "#{BASE_URL}#{key}=#{query}&summary=#{summary}"
      conn = Faraday.new(search) do |r|
        r.get(search).body
      end
      Nokogiri::XML(conn.get(search).body)
    end

    def get_book_data(result)
      isbn = result.css('input').children.text
      isbn_type = define_isbn_type(isbn)
      {
        'origin' => 'OCLC API',
        'title' => result.css('work').attribute('title').value,
        'authors' => result.css('work').attribute('author').value,
        'ddc' => result.css('mostPopular').attribute('nsfa').value,
        isbn_type => isbn
      }
    end

    def recommend_classification(key, query, length = 5, mode: 'ddc')
      results = search_by(key, query)

      response_cases(results, length, mode)
    end

    private

    def get_response_code(result) = result.css('response').attribute('code').value.to_i

    def get_owis(result, length)
      owis = []
      result.css('work').map { |work| owis << work.attribute('owi').value }

      owis[0...length]
    end

    def get_recommendations(owis, mode)
      results = []
      classifications_recommended = []

      owis.map { |owi_value| results << search_by('owi', owi_value) }

      results.each do |classification|
        classifications_recommended << get_classification(classification, mode)
      end

      classifications_recommended
    end

    def get_classification(result, mode)
      acronym = { 'ddc': 'Dewey Decimal Classification',
                  'lcc': 'Library of Congress Classification' }

      result.css(mode).css('mostPopular').attribute('nsfa').value
    rescue NoMethodError
      "A #{acronym[mode.to_sym]} is not available for this book"
    end

    def create_new_book(query)
      volume_info = get_book_data(query.result)
      Alexandrite::Book.new(volume_info)
    end

    def retry_create_new_book(query)
      owi = get_owis(query.result, 1)[0]
      new_query = Alexandrite::OCLC.new('owi', owi)
      volume_info = get_book_data(new_query.result)
      Alexandrite::Book.new(volume_info)
    end

    def handle_error_creating_book(query)
      raise ErrorType::DataNotFound, response_cases(query, 0, 'none')
    rescue StandardError => e
      Alexandrite::Book.new('error_message' => e.message)
    end

    # @param [Nokogiri::XML] result
    # @param [Integer] length
    # @param [String] mode Possible: 'ddc' or 'lcc'
    # @return [String]
    def response_cases(result, length, mode)
      code = get_response_code(result).to_i
      case code
      when 0
        get_classification(result, mode)
      when 2
        get_classification(result, mode)
      when 4
        get_recommendations(get_owis(result, length), mode)
      when 100
        'No input. The method requires an input argument.'
      when 101
        'Invalid input. The standard number argument is invalid.'
      when 102
        'Not found. No data found for the input argument.'
      when 200
        'Unexpected error.'
      end
    end

    def response(response_code, query)
      case response_code
      when 0, 2
        create_new_book(query)
      when 4
        retry_create_new_book(query)
      else
        handle_error_creating_book(query)
      end
    end
  end
end
