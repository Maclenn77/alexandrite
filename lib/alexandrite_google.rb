# frozen_string_literal: true

# require all files
require_relative 'alexandrite/version'
require 'rubygems'
require 'faraday'
require 'json'
require_relative 'helpers/format'
require_relative 'helpers/validation'
require 'pry'

module Alexandrite
  # Methods for consuming Google API
  module GoogleAPI
    include Alexandrite::Helpers::Format
    include Alexandrite::Helpers::Validation

    attr_reader :result, :isbn

    BASE_URL = 'https://www.googleapis.com/books/v1/volumes?q='

    FILTERS = {
      author: 'inauthor:',
      isbn: 'isbn:',
      lccn: 'lccn:',
      oclc: 'oclc:',
      publisher: 'inpublisher:',
      subject: 'subject:',
      title: 'intitle:'
    }.freeze

    FIELDS = {
      title: 'volumeInfo/title',
      authors: 'volumeInfo/authors'
    }.freeze

    # @param query [String]
    # @return [Faraday::Response]
    def search(query, projection: 'lite')
      conn = Faraday.new("#{BASE_URL}#{query}&projection=#{projection}") do |r|
        r.response :json
      end

      conn.get.body
    end

    # @param key [Symbol]
    # @param query [String]
    # @param fields [Array<String>]
    # @return [Faraday::Response]
    def search_by(key, query, projection: 'lite', **fields)
      projection = "&projection=#{projection}"
      url = fields.any? ? "#{BASE_URL}#{FILTERS[key]}#{query}#{add_fields(fields)}#{projection}" : "#{BASE_URL}#{FILTERS[key]}#{query}"
      conn = Faraday.new(url) do |r|
        r.response :json
      end

      response = conn.get.body

      process_response(response)
    end

    private

    def zero_results?(response_body) = response_body['totalItems'].zero?

    def process_response(response)
      if zero_results?(response)
        { error_message: 'Not results' }
      else
        { results_size: response['totalItems'],
          books: response['items'] }
      end
    end
  end
end
