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

      assign_isbn(data, volume_info)

      data
    end

    private

    def assign_isbn(data, volume_info)
      case data[:data_source]
      when 'OCLC API'
        data[:isbn10] = volume_info['ISBN_10']
        data[:isbn13] = volume_info['ISBN_13']
      else
        select_identifiers(data, volume_info)
      end
        data
    end

    def select_identifiers(data, volume_info)
      return data unless volume_info['industryIdentifiers']

      volume_info['industryIdentifiers'].each do |identifier|
        data[:isbn10] = identifier['identifier'] if isbn10?(identifier)
        data[:isbn13] = identifier['identifier'] if isbn13?(identifier)
      end

      data
    end

    def isbn10?(identifier) = identifier['type'] == 'ISBN_10'

    def isbn13?(identifier) = identifier['type'] == 'ISBN_13'
  end
end
