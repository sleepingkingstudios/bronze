# frozen_string_literal: true

require 'bronze/collections/simple/adapter'

RSpec.describe Bronze::Collections::Simple::Adapter do
  subject(:adapter) { described_class.new(raw_data) }

  let(:raw_data) do
    {
      'books' => [
        {
          'title'  => 'The Time Machine',
          'author' => 'H. G. Wells'
        },
        {
          'title'  => 'War of the Worlds',
          'author' => 'H. G. Wells'
        },
        {
          'title'  => 'Journey to the Center of the Earth',
          'author' => 'Jules Verne'
        }
      ]
    }
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#data' do
    include_examples 'should have reader', :data, -> { be == raw_data }
  end

  describe '#query' do
    let(:query_class) { Bronze::Collections::Simple::Query }
    let(:query)       { adapter.query('books') }

    it { expect(adapter).to respond_to(:query).with(1).argument }

    it { expect(adapter.query('books')).to be_a query_class }

    it { expect(query.send(:data)).to be == raw_data['books'] }
  end
end
