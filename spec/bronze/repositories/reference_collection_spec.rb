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
    items = instance.all.to_a

    if items.empty?
      nil
    elsif items.first.is_a?(Hash)
      items.find { |hsh| hsh[:id] == id }
    else
      items.find { |obj| obj.id == id }
    end # if-elsif-else
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the Collection interface'

  include_examples 'should implement the Collection methods'

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    validate_params 'item not found with id 0', :id => 0

    wrap_context 'when the collection contains many items' do
      validate_params 'item not found with id 0', :id => 0
    end # wrap_context
  end # describe

  describe '#update' do
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    validate_params 'item not found with id "0"', :id => '0'

    wrap_context 'when the collection contains many items' do
      validate_params 'item not found with id "0"', :id => '0'
    end # wrap_context
  end # describe
end # describe
