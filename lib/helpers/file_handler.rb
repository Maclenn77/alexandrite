# frozen_string_literal: true

module Alexandrite
  module Helpers
    # Save files of books
    module FileHandler
      # @param [String] file_name
      # @param [Array<Object>] data
      def save(file_name, data)
        File.open(file_name, 'w') { |f| f.write Marshal.dump(data) }
      end

      def open(file_name)
        file = File.open(file_name)
        Marshal.load(file)
      end
    end
  end
end