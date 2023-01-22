# frozen_string_literal: true

require_relative 'alexandrite'
require 'nokogiri'

module Alexandrite
  # Create a book objects
  module BookData
    # @param volume_info [Hash]
    # @return [Hash]
    def self.create_data(volume_info)
      data = add_basic_values(volume_info)
      data[:data_source] = add_origin(volume_info)
      data = add_industry_identifiers(volume_info, data)
      data[:error_message] = volume_info[:error_message]

      data
    end

    def self.add_basic_values(volume_info)
      {
        title: volume_info['title'],
        authors: volume_info['authors'],
        published_date: volume_info['publisher'],
        page_count: volume_info['pageCount'],
        description: volume_info['description'],
        categories: volume_info['categories'],
        language: volume_info['language']

      }
    end

    # @param [Hash] volume_info
    # @return [String]
    def self.add_origin(volume_info) = volume_info['origin'] || 'Google API'

    # @param [Hash] volume_info
    # @param [Hash] data
    # @return [NilClass]
    def self.add_industry_identifiers(volume_info, data)
      return data unless volume_info[:error_message].nil?

      if data[:data_source] == 'OCLC API'
        data[:isbn10] = volume_info['ISBN_10']
        data[:isbn13] = volume_info['ISBN_13']
        return data
      end

      volume_info['industryIdentifiers'].each do |identifier|
        data[:isbn10] = identifier['identifier'] if identifier['type'] == 'ISBN_10'
        data[:isbn13] = identifier['identifier'] if identifier['type'] == 'ISBN_13'
      end

      data
    end
  end
end
