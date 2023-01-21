# frozen_string_literal: true

module Alexandrite
  module Helpers
    # Validate inputs
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

      def define_isbn_type(isbn) = "ISBN_#{isbn.length}"
    end
  end
end
