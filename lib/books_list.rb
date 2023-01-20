require_relative 'alexandrite'
require_relative 'book'

module Alexandrite
  class BooksList
    extend Alexandrite

    def initialize
      @book_list = []

      return "There's not books info" if @@books_info.nil?

      @@books_info.each do |book_info|
        @book_list.push(Alexandrite::Book.new(book_info['volumeInfo']))
      end
    end

    def self.books_info(query) = @@books_info = search(query)['items']
  end
end
