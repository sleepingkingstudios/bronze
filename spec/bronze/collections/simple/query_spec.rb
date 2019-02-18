# frozen_string_literal: true

require 'bronze/collections/simple/query'

require 'support/examples/collections/query_examples'

RSpec.describe Bronze::Collections::Simple::Query do
  include Spec::Support::Examples::Collections::QueryExamples

  subject(:query) { described_class.new(raw_data) }

  let(:raw_data) { [] }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  include_examples 'should implement the Query interface'

  include_examples 'should implement the Query methods'

  describe '#data' do
    include_examples 'should have private reader', :data, -> { be == raw_data }

    wrap_context 'when the data has many items' do
      it { expect(query.send :data).to be == raw_data }
    end
  end

  describe '#matching' do
    context 'when the data has many nested items' do
      let(:raw_data) do
        [
          {
            'title'  => 'Barsoom',
            'author' => { 'name' => 'Edgar Rice Burroughs' },
            'books'  => [
              {
                'title' => 'A Princess of Mars',
                'year'  => 1912
              },
              {
                'title' => 'The Gods of Mars',
                'year'  => 1913
              },
              {
                'title' => 'The Warlord of Mars',
                'year'  => 1914
              }
            ]
          },
          {
            'title'  => 'Pellucidar',
            'author' => { 'name' => 'Edgar Rice Burroughs' },
            'books'  => [
              {
                'title' => "At The Earth's Core",
                'year'  => 1914
              },
              {
                'title' => 'Pellucidar',
                'year'  => 1915
              },
              {
                'title' => 'Tanar of Pellucidar',
                'year'  => 1929
              }
            ]
          },
          {
            'title' => 'Venus',
            'books' => [
              {
                'title' => 'Pirates of Venus',
                'year'  => 1932
              }
            ]
          },
          {
            'title'  => 'Tarzan',
            'author' => { 'name' => 'Edgar Rice Burroughs' }
          },
          {
            'title'  => 'The Lord of the Rings',
            'author' => { 'name' => 'J.R.R. Tolkien' }
          }
        ]
      end

      describe 'with a nested index selector' do
        let(:selector) do
          { 'books' => { 1 => { 'title' => 'The Gods of Mars' } } }
        end
        let(:subquery) { query.matching(selector) }
        let(:expected_data) do
          raw_data.select do |hsh|
            hsh.dig('books', 1, 'title') == 'The Gods of Mars'
          end
        end

        it { expect(subquery.count).to be expected_data.size }

        it { expect(subquery.to_a).to be == expected_data }
      end

      describe 'with a nested value selector' do
        let(:selector) { { 'author' => { 'name' => 'Edgar Rice Burroughs' } } }
        let(:subquery) { query.matching(selector) }
        let(:expected_data) do
          raw_data.select do |hsh|
            hsh.dig('author', 'name') == 'Edgar Rice Burroughs'
          end
        end

        it { expect(subquery.count).to be expected_data.size }

        it { expect(subquery.to_a).to be == expected_data }
      end
    end
  end
end
