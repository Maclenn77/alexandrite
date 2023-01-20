# frozen_string_literal: false

require 'spec_helper'
require 'pry'

describe 'validate ISBN format' do
  let(:book_class) { Class.new  }

  describe 'valid ISBNs' do
    let(:valid_isbn10) { '0123456789' }
    let(:valid_isbn13) { '1234567890123' }
    let(:valid_isbn_non_digit) { '1-23456789012-3' }

    it 'valid ISBN of 13 digits' do
      isbn = valid_isbn13
      result = book_class.validate_isbn(isbn)
      expect(result).to eq(valid_isbn13)
    end

    it 'valid ISBN of 10 digits' do
      result = book_class.validate_isbn(valid_isbn10)
      expect(result).to eq(valid_isbn10)
    end

    it 'valid ISBN with dashes' do
      result = book_class.validate_isbn(valid_isbn_non_digit)
      expect(result).to eq(valid_isbn13)
    end
  end

  describe 'invalid ISBNs' do
    let(:error_message) { 'ISBN should have 10 or 13 digits' }
    let(:valid_isbn_white_spaces) { '1234567890123 ' }
    let(:invalid_isbn_non_digit) { 'ABCDEFGHIJ ' }
    let(:invalid_isbn_too_short) { '1234' }
    let(:invalid_isbn_too_long) { '123456789123456789' }

    it 'ISBN without digits is invalid' do
      result = book_class.validate_isbn(invalid_isbn_non_digit)
      expect(result).to eq(error_message)
    end

    it 'ISBN is invalid because is too short' do
      result = book_class.validate_isbn(invalid_isbn_too_short)
      expect(result).to eq(error_message)
    end

    it 'ISBN is invalid because is too long' do
      result = book_class.validate_isbn(invalid_isbn_too_short)
      expect(result).to eq(error_message)
    end
  end
end
