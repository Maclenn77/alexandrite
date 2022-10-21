# frozen_string_literal: true

# require all files
require 'alexandrite/version'
require 'rubygems'
require 'faraday'
require 'json'
require_relative 'helpers/format'
require_relative 'helpers/validation'

module Alexandrite
  module Fetcher
    include Alexandrite::Helpers::Format
    include Alexandrite::Helpers::Validation

    attr_reader :result, :isbn

    BASE_URL = 'https://www.googleapis.com/books/v1/volumes?q='

    FILTERS = {
      author: 'inauthor:', isbn: 'isbn:',
      lccn: 'lccn:',
      oclc: 'oclc:',
      publisher: 'inpublisher:',
      subject: 'subject:',
      title: 'intitle:'
    }.freeze

    # @param query [String]
    # @return [Faraday::Response]
    def search(query)
      Faraday.get("#{BASE_URL}#{query}")
    end

    # @param keys [Symbol]
    # @param queries [Array<String>]
    # @return [Faraday::Response]
    def search_by(*keys, queries)
      url = BASE_URL
      keys.zip(queries) do |key, query|
        url += "#{FILTERS[key]}#{query}"
      end
      url
    end


    # Description of the book
    #
    # Example:
    #   >> alexandrite_base.description
    #   => "A new edition of the essential text and professional reference, with substantial newmaterial on such topics as vEB trees,
    #       multithreaded algorithms, dynamic programming, and edge-baseflow."
    #
    # @return [String]
    def description
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['description']
    end

    # Title of the book
    # Example:
    #   >> alexandrite_base.title
    #   => "Introduction to Algorithms"
    #
    # Return:
    #     String
    def title
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['title']
    end

    # It returns all authors' name as comma separated string
    #
    # Example:
    #   >> alexandrite_base.authors
    #   => "harles E. Leiserson, Clifford Stein, Ronald Rivest,Thomas H. Cormen"
    #
    # Return:
    #     String
    def authors
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['authors'].join(', ')
    end

    # It returns all authors' name as array
    #
    # Example:
    #   >> alexandrite_base.authors_as_array
    #   => ["harles E. Leiserson", "Clifford Stein", "Ronald Rivest", "Thomas H. Cormen"]
    #
    # Return:
    #     array
    def authors_as_array
      return [] if @result.nil?

      @result['items'][0]['volumeInfo']['authors']
    end

    # It returns publisher name
    #
    # Example:
    #   >> alexandrite_base.publisher
    #   => "MIT Press"
    #
    # Return:
    #     String
    def publisher
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['publisher']
    end

    # It returns the ten digit ISBN number of book
    #
    # Example:
    #   >> alexandrite_base.isbn_10
    #   => "0262033844"
    #
    # Return:
    #     the ten digit numbers
    def isbn10
      return nil if @result.nil?

      isbn_array = @result['items'][0]['volumeInfo']['industryIdentifiers']

      isbn_array.each do |isbn|
        return isbn['identifier'] if isbn['type'] == 'ISBN_10'
      end
    end

    # It returns the thirteen digit ISBN number of book
    #
    # Example:
    #   >> alexandrite_base.isbn_13
    #   => "9780262033848"
    #
    # Return:
    #     the thirteen digit number
    def isbn13
      return nil if @result.nil?

      isbn_array = @result['items'][0]['volumeInfo']['industryIdentifiers']

      isbn_array.each do |isbn|
        return isbn['identifier'] if isbn['type'] == 'ISBN_13'
      end
    end

    # It returns categories of book
    #
    # Example:
    #   >> alexandrite_base.categories
    #   => "Computers"
    #
    # Return:
    #     String
    def categories
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['categories'].join(', ')
    end

    # It returns categories of book as array
    #
    # Example:
    #   >> alexandrite_base.categories
    #   => ["Computers"]
    #
    # Return:
    #     array
    def categories_as_array
      return [] if @result.nil?

      @result['items'][0]['volumeInfo']['categories']
    end

    # It returns the link of small size thumbnail of book
    #
    # Example:
    #   >> alexandrite_base.small_thumbnail
    #   => "http://books.google.com/books/content?id=i-bUBQAAQBAJ&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api"
    #
    # Return:
    #     String
    def thumbnail_small
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['imageLinks']['smallThumbnail']
    end

    # It returns the link of thumbnail of book
    #
    # Example:
    #   >> alexandrite_base.thumbnail
    #   => "http://books.google.com/books/content?id=i-bUBQAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
    #
    # Return:
    #     String
    def thumbnail
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['imageLinks']['thumbnail']
    end

    # It returns the preview link of book
    #
    # Example:
    #   >> alexandrite_base.preview_link
    #   => "http://books.google.ca/books?id=i-bUBQAAQBAJ&printsec=frontcover&dq=isbn:0262033844&hl=&cd=1&source=gbs_api"
    #
    # Return:
    #     String
    def preview_link
      return nil if @result.nil?

      @result['items'][0]['volumeInfo']['previewLink']
    end

    # It returns the count of page
    #
    # Example:
    #   >> alexandrite_base.page_count
    #   => 1292
    #
    # Return:
    #     int
    def page_count
      return 0 if @result.nil?

      @result['items'][0]['volumeInfo']['pageCount']
    end

    # It returns the published date
    #
    # Example:
    #   >> alexandrite_base.published_date
    #   => #<Date: 2009-07-31 ((2455044j,0s,0n),+0s,2299161j)>
    #
    # Return:
    #     Date
    def published_date
      return nil if @result.nil?

      begin
        Date.parse(@result['items'][0]['volumeInfo']['publishedDate'])
      rescue ArgumentError
        @result['items'][0]['volumeInfo']['publishedDate']
      end
    end
  end
end
