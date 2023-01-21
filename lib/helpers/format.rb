# frozen_string_literal: true

module Alexandrite
  module Helpers
    # Format inputs and options
    module Format
      # @param string [String]
      # @return [String]
      def remove_non_digits(string)
        string.gsub!(/[^+\d]/, '')
      end

      def add_fields(*fields)
        "&fields=items(volumeInfo/#{fields.join(',volumeInfo/')})"
      end
    end
  end
end
