# spec/bronze/repositories/reference_collection_spec.rb

require 'bronze/repositories/reference_collection'
require 'bronze/repositories/reference_query'

RSpec.describe Spec::ReferenceCollection do
  shared_context 'when the collection contains many items' do
    let(:data) do
      [
        { :title => 'The Fellowship of the Ring' },
        { :title => 'The Two Towers' },
        { :title => 'The Return of the King' }
      ] # end array
    end # let
  end # shared_context

  let(:name)        { :books }
  let(:data)        { [] }
  let(:instance)    { described_class.new name, data }
  let(:query_class) { Spec::ReferenceQuery }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  describe '#all' do
    it { expect(instance).to respond_to(:all).with(0).arguments }

    it 'should return a query' do
      query = instance.all

      expect(query).to be_a query_class
      expect(query.to_a).to be == []
    end # it

    wrap_context 'when the collection contains many items' do
      it 'should return a query' do
        query = instance.all

        expect(query).to be_a query_class
        expect(query.to_a).to contain_exactly(*data)
      end # it
    end # wrap_context
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it { expect(instance.count).to be 0 }

    wrap_context 'when the collection contains many items' do
      it { expect(instance.count).to be == data.count }
    end # wrap_context
  end # describe

  describe '#name' do
    include_examples 'should have reader', :name, ->() { name }
  end # describe
end # describe
