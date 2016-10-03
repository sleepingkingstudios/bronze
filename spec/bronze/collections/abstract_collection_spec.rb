# spec/bronze/collections/abstract_collection_spec.rb

require 'bronze/collections/abstract_collection'
require 'bronze/collections/collection_examples'

RSpec.describe Bronze::Collections::AbstractCollection do
  include Spec::Collections::CollectionExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  describe '#count' do
    it 'should raise an error' do
      expect { instance.count }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#delete' do
    it 'should raise an error' do
      expect { instance.delete '0' }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :delete_one"
    end # it
  end # describe

  describe '#find' do
    it 'should raise an error' do
      expect { instance.find '0' }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#insert' do
    it 'should raise an error' do
      expect { instance.insert({}) }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :insert_one"
    end # it
  end # describe

  describe '#limit' do
    it 'should raise an error' do
      expect { instance.limit(3) }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#matching' do
    it 'should raise an error' do
      expect { instance.matching({}) }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#none' do
    it 'should raise an error' do
      expect { instance.none }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#query' do
    it 'should raise an error' do
      expect { instance.query }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#to_a' do
    it 'should raise an error' do
      expect { instance.to_a }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#update' do
    it { expect(instance).to respond_to(:update).with(2).arguments }

    it 'should raise an error' do
      expect { instance.update('0', {}) }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :update_one"
    end # it
  end # describe
end # describe
