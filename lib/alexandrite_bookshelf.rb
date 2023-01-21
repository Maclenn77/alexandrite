# frozen_string_literal: true

require_relative 'alexandrite'
require_relative 'book'

# Create, Read, Update and Delete books in a book collection
module Alexandrite
  # Create a collection of books
  class Bookshelf
    def initialize
      @book_collection = []
    end
  end
  def add_book(book) = @book_collection << book if book.instance_of?(Alexandrite::Book)
end
