# frozen_string_literal: true

require 'bronze/collections/adapter'

RSpec.describe Bronze::Collections::Adapter do
  subject(:adapter) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#query' do
    let(:error_message) do
      'Bronze::Collections::Adapter#query is not implemented'
    end

    it { expect(adapter).to respond_to(:query).with(1).argument }

    it 'should raise an error' do
      expect { adapter.query('books') }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end
end
