# spec/patina/repositories/simple/collection_spec.rb

require 'bronze/repositories/collection_examples'
require 'patina/repositories/simple/collection'
require 'patina/repositories/simple/query'

RSpec.describe Patina::Repositories::Simple::Collection do
  include Spec::Repositories::CollectionExamples

  shared_context 'when the collection contains many items' do
    let(:data) do
      [
        { :id => '1', :title => 'The Fellowship of the Ring' },
        { :id => '2', :title => 'The Two Towers' },
        { :id => '3', :title => 'The Return of the King' }
      ] # end array
    end # let

    before(:example) do
      data.each do |attributes|
        instance.insert attributes
      end # each
    end # before example
  end # shared_context

  let(:instance)    { described_class.new }
  let(:query_class) { Patina::Repositories::Simple::Query }

  def find_item id
    instance.all.to_a.find { |hsh| hsh[:id] == id }
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
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

    validate_params "id can't be nil", :id => nil

    validate_params 'item not found with id "0"', :id => '0'

    wrap_context 'when the collection contains many items' do
      validate_params "id can't be nil", :id => nil

      validate_params 'item not found with id "0"', :id => '0'

      describe 'with a valid id' do
        let(:id) { '1' }

        include_examples 'should delete the item'
      end # describe
    end # wrap_context
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    validate_params "data can't be nil", :attributes => nil

    validate_params 'data must be a Hash', :attributes => Object.new

    validate_params "id can't be nil", :attributes => {}

    validate_params "id can't be nil", :attributes => { :title => 'The Hobbit' }

    describe 'with an attributes Hash' do
      let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

      include_examples 'should insert the item'
    end # describe

    wrap_context 'when the collection contains many items' do
      validate_params "data can't be nil", :attributes => nil

      validate_params 'data must be a Hash', :attributes => Object.new

      validate_params "id can't be nil", :attributes => {}

      validate_params "id can't be nil",
        :attributes => { :title => 'The Hobbit' }

      validate_params 'id already exists',
        :attributes => { :id => '1', :title => 'The Hobbit' }

      describe 'with an attributes Hash with a new id' do
        let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

        include_examples 'should insert the item'
      end # describe
    end # wrap_context
  end # describe

  describe '#update' do
    let(:id)         { '1' }
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    validate_params "id can't be nil", :id => nil

    validate_params 'item not found with id "0"', :id => '0'

    wrap_context 'when the collection contains many items' do
      validate_params "id can't be nil", :id => nil

      validate_params 'item not found with id "0"', :id => '0'

      validate_params "data can't be nil", :attributes => nil

      validate_params 'data must be a Hash', :attributes => Object.new

      validate_params 'data id must match id', :attributes => { :id => 1 }

      describe 'with a valid id and a valid attributes hash' do
        let(:id)         { '3' }
        let(:attributes) { { :title => 'The Revenge of the Sith' } }

        include_examples 'should update the item'
      end # describe
    end # wrap_context
  end # describe
end # describe
