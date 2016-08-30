# spec/bronze/collections/null_collection_spec.rb

require 'bronze/collections/null_collection'
require 'bronze/collections/null_query'

RSpec.describe Bronze::Collections::NullCollection do
  include Spec::Collections::CollectionExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  describe '#all' do
    it 'should return a null query' do
      query = instance.all

      expect(query).to be_a Bronze::Collections::NullQuery
    end # it
  end # describe

  describe '#count' do
    it { expect(instance.count).to be 0 }
  end # describe

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    validate_params 'item not found with id "0"', :id => '0'
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    validate_params 'item not inserted', :attributes => {}
  end # describe

  describe '#matching' do
    it 'should return a null query' do
      query = instance.matching({})

      expect(query).to be_a Bronze::Collections::NullQuery
    end # it
  end # describe

  describe '#update' do
    def perform_action
      instance.update id, attributes
    end # method perform_action

    validate_params 'item not found with id "0"', :id => '0', :attributes => {}
  end # describe
end # describe
