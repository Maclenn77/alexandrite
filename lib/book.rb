# frozen_string_literal: true

require_relative 'alexandrite'

module Alexandrite
  class Book
    extend Alexandrite

    @@collection = []


    attr_reader :title, :authors, :publisher, :published_date, :page_count, :description, :categories, :language,
                :country, :isbn10, :isbn13

    # @param volumeInfo [Hash]
    # @return [Alexandrite::Book]
    def initialize(volume_info)
      @title = volume_info['title']
      @authors = volume_info['authors']
      @publisher = volume_info['publisher']
      @published_date = volume_info['publishedDate']
      @page_count = volume_info['pageCount']
      @description = volume_info['description']
      @categories = volume_info['categories']
      @language = volume_info['language']
      volume_info['industryIdentifiers'].each do |identifier|
        @isbn10 = identifier['identifier'] if identifier['type'] == 'ISBN_10'
        @isbn13 = identifier['identifier'] if identifier['type'] == 'ISBN_13'
      end
    end

    # @param isbns [Array]
    # @return [Nil]
    def self.bulk_create(isbns)
      isbns.each do |isbn|
        volume_info = volume_info(isbn)
        book = Alexandrite::Book.new(volume_info)
        add_to_collection(book)
      end

      nil
    end

    def self.volume_info(isbn) = search_by(:isbn, isbn)[:books].first['volumeInfo']

    def self.collection = @@collection

    def self.add_to_collection(book)
      @@collection.push(book)
    end

    private

    def add_isbns(identifiers)

    end
  end
end
