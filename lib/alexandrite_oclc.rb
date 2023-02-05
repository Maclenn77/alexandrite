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
    include Alexandrite::BookData

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

    def extract_value(attribute)
      return nil unless attribute.respond_to?(:value)

      attribute.value
    end

    def extract_nokogiri_data(document, children, attribute)
      extract_value(document.css(children).attribute(attribute))
    end

    def get_book_data(result)
      isbn = result.css('input').children.text
      isbn_type = define_isbn_type(isbn)
      {
        'origin' => 'OCLC API',
        'title' => extract_nokogiri_data(result, 'work', 'title'),
        'authors' => extract_nokogiri_data(result, 'work', 'author'),
        'ddc' => extract_nokogiri_data(result, 'mostPopular', 'nsfa'),
        isbn_type => isbn
      }
    end

    def recommend_classification(key, query, length = 5, mode: 'ddc')
      results = search_by(key, query)
      response_cases(results, length, mode)
    end

    private

    # @return [Integer]
    def get_response_code(result) = extract_nokogiri_data(result, 'response', 'code').to_i

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
      Alexandrite::BookData.create_data(get_book_data(query.result))
    rescue StandardError => e
      Alexandrite::BookData.create_data({ :error_message => e.message, 'origin' => 'OCLC API' })
    end

    def handle_error_creating_book
      raise ErrorType::DataNotFound, yield
    rescue StandardError => e
      Alexandrite::BookData.create_data({ :error_message => e.message, 'origin' => 'OCLC API' })
    end

    # @param [Nokogiri::XML] result
    # @param [Integer] length
    # @param [String] mode Possible: 'ddc' or 'lcc'
    # @return [String]
    def response_cases(result, length, mode)
      code = get_response_code(result)
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
        handle_error_creating_book { 'Not found exact item. Check coincidences' }
      else
        handle_error_creating_book { response_cases(query.result, 0, 'none') }
      end
    end
  end
end
