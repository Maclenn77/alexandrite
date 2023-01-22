# frozen_string_literal: true

require_relative 'alexandrite'
require 'nokogiri'

module Alexandrite
  # Create a book objects
  class Book
    attr_accessor :title, :authors, :publisher, :published_date, :page_count, :description, :categories, :language,
                  :country, :isbn10, :isbn13, :error_message, :ddc, :lcc, :suggested_classifications

    # @param volume_info [Hash]
    # @return [Alexandrite::Books]
    def initialize(volume_info)
      add_origin(volume_info)
      add_basic_values(volume_info)
      add_industry_identifiers(volume_info, @origin)
      @error_message = volume_info[:error_message]
    end

    def self.collection = @@collection

    def self.add_to_collection(book)
      @@collection.push(book)
    end

    # @param [String] ddc_code
    # @return [NilClass]
    def add_ddc(ddc_code) = @ddc = ddc_code

    # @param [String] lcc_code
    # @return [NilClass]
    def add_lcc(lcc_code) = @lcc = lcc_code

    # @param [Array<String>] suggestions
    # @return [NilClass]
    def add_classification_suggested(suggestions) = @suggested_classifications = suggestions

    private

    def add_basic_values(volume_info)
      @title = volume_info['title']
      @authors = volume_info['authors']
      @publisher = volume_info['publisher']
      @published_date = volume_info['publishedDate']
      @page_count = volume_info['pageCount']
      @description = volume_info['description']
      @categories = volume_info['categories']
      @language = volume_info['language']
    end

    # @param [Hash] volume_info
    # @return [String]
    def add_origin(volume_info) = @origin = volume_info['origin'] || 'Google API'

    # @param [Hash] volume_info
    # @param [String] origin
    # @return [NilClass]
    def add_industry_identifiers(volume_info, origin)
      return nil unless volume_info[:error_message].nil?

      if origin == 'OCLC API'
        @isbn10 = volume_info['ISBN_10']
        @isbn13 = volume_info['ISBN_13']
        return
      end

      volume_info['industryIdentifiers'].each do |identifier|
        @isbn10 = identifier['identifier'] if identifier['type'] == 'ISBN_10'
        @isbn13 = identifier['identifier'] if identifier['type'] == 'ISBN_13'
      end
    end
  end
end
