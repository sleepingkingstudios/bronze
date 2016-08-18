# spec/bronze/repositories/collection_spec.rb

require 'bronze/repositories/collection'
require 'bronze/repositories/reference_collection'

RSpec.describe Bronze::Repositories::Collection do
  let(:name)     { :books }
  let(:instance) { described_class.new name }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#all' do
    it { expect(instance).to respond_to(:all).with(0).arguments }

    it 'should raise an error' do
      expect { instance.all }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it 'should raise an error' do
      expect { instance.count }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :base_query"
    end # it
  end # describe

  describe '#name' do
    include_examples 'should have reader', :name, ->() { name }
  end # describe
end # describe
