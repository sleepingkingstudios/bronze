# spec/patina/collections/mongo/query_spec.rb

require 'bronze/collections/query_examples'
require 'bronze/transforms/identity_transform'

require 'patina/collections/mongo/primary_key_transform'
require 'patina/collections/mongo/query'

RSpec.describe Patina::Collections::Mongo::Query do
  include Spec::Collections::QueryExamples

  let(:transform) do
    Bronze::Transforms::IdentityTransform.new
  end # let
  let(:raw_data) { [] }
  let(:data) do
    hash_tools = SleepingKingStudios::Tools::HashTools

    raw_data.map { |hsh| hash_tools.convert_keys_to_strings(hsh) }
  end # let
  let(:mongo_collection) { Spec.mongo_client[:books] }
  let(:instance)         { described_class.new(mongo_collection, transform) }

  around(:example) do |example|
    begin
      mongo_collection.delete_many

      mapped = data.map do |hsh|
        hsh = hsh.dup

        hsh['_id'] = hsh.delete('id') if hsh.key?('id')

        hsh
      end # mapped

      mongo_collection.insert_many(mapped)

      example.call
    ensure
      mongo_collection.delete_many
    end # begin-ensure
  end # before context

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  include_examples 'should implement the Query interface'

  include_examples 'should implement the Query methods' do
    let(:expected_selector) do
      hsh = selector.dup

      hsh[:_id] = hsh.delete(:id) if hsh.key?(:id)

      hsh
    end # let
  end # include_examples

  describe '#mongo_collection' do
    include_examples 'should have reader',
      :mongo_collection,
      ->() { mongo_collection }
  end # describe

  describe '#transform' do
    it 'should chain the transform with a primary key transform' do
      result = instance.transform

      expect(result).to be_a Bronze::Transforms::TransformChain

      transforms = instance.transform.transforms
      expect(transforms.count).to be 2
      expect(transforms.first).to be transform
      expect(transforms.last).
        to be_a Patina::Collections::Mongo::PrimaryKeyTransform
    end # it
  end # describe
end # describe
