# frozen_string_literal: true

module Alexandrite
  module Helpers
    module Validation
      # @param
      # @return
      def valid_isbn_length?(isbn) = isbn.size == 10 || isbn.size == 13

      # @param
      # @return [String] or [Nil]
      def validate_isbn(isbn)
        remove_non_digits(isbn.to_s)
        return isbn if valid_isbn_length?(isbn)

        'ISBN should have 10 or 13 digits'
      end
    end
  end
end
