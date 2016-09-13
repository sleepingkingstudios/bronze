# spec/bronze/collections/null_collection_spec.rb

require 'bronze/collections/collection_examples'
require 'bronze/collections/null_collection'
require 'bronze/collections/null_query'

RSpec.describe Bronze::Collections::NullCollection do
  include Spec::Collections::CollectionExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  describe '#count' do
    it { expect(instance.count).to be 0 }
  end # describe

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    with_params :id => 0 do
      include_examples 'should fail with error',
        described_class::Errors::READ_ONLY_COLLECTION
    end # with_params
  end # describe

  describe '#find' do
    it { expect(instance.find '0').to be nil }
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    with_params :attributes => {} do
      include_examples 'should fail with error',
        described_class::Errors::READ_ONLY_COLLECTION
    end # with_params
  end # describe

  describe '#limit' do
    it 'should return a null query' do
      query = instance.limit(0)

      expect(query).to be_a Bronze::Collections::NullQuery
    end # it
  end # describe

  describe '#matching' do
    it 'should return a null query' do
      query = instance.matching({})

      expect(query).to be_a Bronze::Collections::NullQuery
    end # it
  end # describe

  describe '#none' do
    it 'should return a null query' do
      query = instance.none

      expect(query).to be_a Bronze::Collections::NullQuery
    end # it
  end # describe

  describe '#one' do
    it { expect(instance.one).to be nil }
  end # describe

  describe '#pluck' do
    it 'should return an empty array' do
      expect(instance.pluck :id).to be == []
    end # it
  end # describe

  describe '#query' do
    it 'should return a null query' do
      query = instance.query

      expect(query).to be_a Bronze::Collections::NullQuery
    end # it
  end # describe

  describe '#to_a' do
    it 'should return an empty array' do
      expect(instance.to_a).to be == []
    end # it
  end # describe

  describe '#update' do
    def perform_action
      instance.update id, attributes
    end # method perform_action

    with_params :id => 0, :attributes => {} do
      include_examples 'should fail with error',
        described_class::Errors::READ_ONLY_COLLECTION
    end # with_params
  end # describe
end # describe
