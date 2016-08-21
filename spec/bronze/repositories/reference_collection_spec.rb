# spec/bronze/repositories/reference_collection_spec.rb

require 'bronze/repositories/collection_examples'
require 'bronze/repositories/reference_collection'
require 'bronze/repositories/reference_query'

RSpec.describe Spec::ReferenceCollection do
  include Spec::Repositories::CollectionExamples

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
    include_examples 'should implement #all'
  end # describe

  describe '#count' do
    include_examples 'should implement #count'
  end # describe

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    include_examples 'should implement #delete'

    validate_params 'item not found with id 0', :id => 0

    wrap_context 'when the collection contains many items' do
      validate_params 'item not found with id 0', :id => 0
    end # wrap_context
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    include_examples 'should implement #insert'
  end # describe

  describe '#update' do
    let(:id)         { '1' }
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    include_examples 'should implement #update'

    validate_params 'item not found with id "0"', :id => '0'

    wrap_context 'when the collection contains many items' do
      validate_params 'item not found with id "0"', :id => '0'
    end # wrap_context
  end # describe
end # describe
