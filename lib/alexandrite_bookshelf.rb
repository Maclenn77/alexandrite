# frozen_string_literal: true

require_relative 'alexandrite'
require_relative 'alexandrite_book'
require_relative 'helpers/file_handler'

# Create, Read, Update and Delete books in a book collection
module Alexandrite
  # Create a collection of books
  class Bookshelf
    extend Alexandrite::Helpers::FileHandler

    @@library = {}

    attr_accessor :book_collection

    attr_reader :collection_name

    def initialize(collection_name, books = nil)
      @collection_name = collection_name.to_sym
      @book_collection = [books]
    end

    def save_bookshelf(file_path)
      save(file_path, self)
    end

    def self.add_bookshelf(file_path)
      bookshelf = open(file_path)
      @@library[bookshelf.collection_name.to_sym] = bookshelf if bookshelf.instance_of?(Alexandrite::Bookshelf)
    end

    def self.charge_library(file_path)
      bookshelves = open(file_path)
      @@library = bookshelves if bookshelves.all?(Alexandrite::Bookshelf)
    end

    def self.save_library(file_path)
      save(file_path, @@library)
    end

    def self.show_library
      @@library
    end

    def self.find_bookshelf(bookshelf_name)
      query = @@library[bookshelf_name.to_sym]
      return "Bookshelf wasn't found. Check collection name" if query.nil?

      query
    end
  end
end
