# spec/bronze/repositories/reference_collection_spec.rb

require 'bronze/repositories/collection_examples'
require 'bronze/repositories/reference_collection'
require 'bronze/repositories/reference_query'

RSpec.describe Spec::ReferenceCollection do
  include Spec::Repositories::CollectionExamples

  shared_context 'when the collection contains many items' do
    let(:data) do
      [
        { :id => 1, :title => 'The Fellowship of the Ring' },
        { :id => 2, :title => 'The Two Towers' },
        { :id => 3, :title => 'The Return of the King' }
      ] # end array
    end # let
  end # shared_context

  let(:data)        { [] }
  let(:instance)    { described_class.new data }
  let(:query_class) { Spec::ReferenceQuery }

  def find_item id
    instance.all.to_a.find { |hsh| hsh[:id] == id }
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the Collection interface'

  describe '#all' do
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
    it { expect(instance.count).to be 0 }

    wrap_context 'when the collection contains many items' do
      it { expect(instance.count).to be == data.count }
    end # wrap_context
  end # describe

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    validate_params 'item not found with id 0', :id => 0

    wrap_context 'when the collection contains many items' do
      validate_params 'item not found with id 0', :id => 0

      describe 'with a valid id' do
        let(:id) { 1 }

        include_examples 'should delete the item'
      end # describe
    end # wrap_context
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    describe 'with an attributes hash' do
      let(:attributes) { { :id => 0, :title => 'The Hobbit' } }

      include_examples 'should insert the item'
    end # describe

    wrap_context 'when the collection contains many items' do
      describe 'with an attributes hash' do
        let(:attributes) { { :id => 0, :title => 'The Hobbit' } }

        include_examples 'should insert the item'
      end # describe
    end # wrap_context
  end # describe

  describe '#update' do
    let(:id)         { 1 }
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    validate_params 'item not found with id 0', :id => 0

    wrap_context 'when the collection contains many items' do
      let(:attributes) { { :author => 'J.R.R. Tolkien' } }

      validate_params 'item not found with id 0', :id => 0

      describe 'with a valid id and an attributes hash' do
        let(:id) { 1 }

        include_examples 'should update the item'
      end # describe
    end # wrap_context
  end # describe
end # describe
