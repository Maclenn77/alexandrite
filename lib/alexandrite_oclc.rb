# frozen_string_literal: true

# require all files
require_relative 'alexandrite/version'
require 'rubygems'
require 'faraday'
require "faraday/decode_xml"
require 'json'
require_relative 'helpers/format'
require_relative 'helpers/validation'
require 'pry'
require 'nokogiri'

module Alexandrite
  module OCLC
    include Nokogiri

    BASE_URL = 'http://classify.oclc.org/classify2/Classify?'

    # @param query [String]
    # @return [Faraday::Response]
    def search_by(key, query, summary: true)
      search = "#{BASE_URL}#{key}=#{query}&summary=#{summary.to_s}"
      conn = Faraday.new(search) do |r|
        r.get(search).body
      end
      Nokogiri::XML(conn.get(search).body)
    end

    def recommend_classification(key, query, length = 5, mode: 'ddc')
      results = search_by(key, query)

      response_cases(results, length, mode)
    end

    private

    def get_response_code(result) = result.css('response').attribute('code').value

    def get_owis(result, length)
      owis = []
      result.css('work').map { |work| owis << work.attribute('owi').value }

      owis[0...length]
    end

    def get_recommendations(owis, mode)
      results = []
      classifications_recommended = []

      owis.map { |owi_value| results << search_by("owi", owi_value) }

      results.each do |classification|
        classifications_recommended << get_classification(classification, mode)
      end

      classifications_recommended
    end

    def get_classification(result, mode)
      acronym = {'ddc': 'Dewey Decimal Classification',
                 'lcc': 'Library of Congress Classification'
      }

      result.css(mode).css('mostPopular').attribute('nsfa').value
    rescue NoMethodError
      "A #{acronym[mode.to_sym]} is not available for this book"
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
        "No input. The method requires an input argument."
      when 101
        "Invalid input. The standard number argument is invalid."
      when 102
        'Not found. No data found for the input argument.'
      when 200
        'Unexpected error.'
      end
    end
  end
end
