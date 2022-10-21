# frozen_string_literal: false

require 'spec_helper'

RSpec.describe Alexandrite::Book do
  subject { Alexandrite::Book.new('0262033844') }

  describe 'alexandrite_base' do
    describe '#process' do
      let(:expected_title) { 'Introduction to Algorithms, Third Edition' }
      let(:expected_pages) { 1314 }
      let(:result) { subject.fetch }

      VCR.use_cassette('get_book') do
        it 'book title' do
          expect(result.title.downcase).to eq(expected_title.downcase)
        end

        it 'book page count' do
          expect(result.page_count.to_i).to eq(expected_pages)
        end
      end
    end
  end
end
