# frozen_string_literal: true

module Alexandrite
  module Helpers
    module Format
      # @param string [String]
      # @return [String]
      def remove_non_digits(string)
        string.gsub!(/[^+\d]/, '')
      end
    end
  end
end
