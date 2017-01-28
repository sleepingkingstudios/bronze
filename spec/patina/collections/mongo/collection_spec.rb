# spec/patina/collections/mongo/collection_spec.rb

require 'bronze/collections/collection_examples'
require 'bronze/transforms/identity_transform'

require 'patina/collections/mongo/collection'

RSpec.describe Patina::Collections::Mongo::Collection do
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
  include Spec::Collections::CollectionExamples

  let(:raw_data) { [] }
  let(:data) do
    hash_tools = SleepingKingStudios::Tools::HashTools

    raw_data.map { |hsh| hash_tools.convert_keys_to_strings(hsh) }
  end # let
  let(:mongo_collection) { Spec.mongo_client[:books] }
  let(:instance)         { described_class.new mongo_collection }
  let(:query_class)      { Patina::Collections::Mongo::Query }

  def find_item id
    raw = mongo_collection.find('_id' => id).first

    instance.transform.denormalize(raw)
  end # method find_item

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
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  include_examples 'should implement the Collection methods' do
    let(:default_transform_class) do
      Patina::Collections::Mongo::PrimaryKeyTransform
    end # let
  end # include_examples

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    with_params :id => nil do
      include_examples 'should fail with error',
        described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
    end # with_params

    with_params :id => 0 do
      include_examples 'should fail with error',
        described_class::Errors::RECORD_NOT_FOUND, :id => 0
    end # with_params

    wrap_context 'when the collection contains many items' do
      with_params :id => nil do
        include_examples 'should fail with error',
          described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
      end # with_params

      with_params :id => 0 do
        include_examples 'should fail with error',
          described_class::Errors::RECORD_NOT_FOUND, :id => 0
      end # with_params
    end # wrap_context
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    with_params :attributes => nil do
      include_examples 'should fail with error',
        described_class::Errors::DATA_MISSING
    end # with_params

    invalid_attributes = Struct.new(:id).new
    with_params :attributes => invalid_attributes do
      include_examples 'should fail with error',
        described_class::Errors::DATA_INVALID, :attributes => invalid_attributes
    end # with_params

    with_params :attributes => {} do
      include_examples 'should fail with error',
        described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
    end # with_params

    with_params :attributes => { :title => 'The Hobbit' } do
      include_examples 'should fail with error',
        described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
    end # with_params

    wrap_context 'when the collection contains many items' do
      with_params :attributes => nil do
        include_examples 'should fail with error',
          described_class::Errors::DATA_MISSING
      end # with_params

      invalid_attributes = Struct.new(:id).new
      with_params :attributes => invalid_attributes do
        include_examples 'should fail with error',
          described_class::Errors::DATA_INVALID,
          :attributes => invalid_attributes
      end # with_params

      with_params :attributes => {} do
        include_examples 'should fail with error',
          described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
      end # with_params

      with_params :attributes => { :title => 'The Hobbit' } do
        include_examples 'should fail with error',
          described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
      end # with_params

      with_params :attributes => { :id => '1', :title => 'The Hobbit' } do
        include_examples 'should fail with error',
          described_class::Errors::RECORD_ALREADY_EXISTS, :id => '1'
      end # with_params
    end # wrap_context
  end # describe

  describe '#mongo_collection' do
    include_examples 'should have reader',
      :mongo_collection,
      ->() { mongo_collection }
  end # describe

  describe '#transform' do
    it 'should chain the transform with a primary key transform' do
      expect(instance.transform).
        to be_a Patina::Collections::Mongo::PrimaryKeyTransform
    end # it

    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new data, transform }

      it 'should chain the transform with a primary key transform' do
        result = instance.transform

        expect(result).to be_a Bronze::Transforms::TransformChain

        transforms = instance.transform.transforms
        expect(transforms.count).to be 2
        expect(transforms.first).to be transform
        expect(transforms.last).
          to be_a Patina::Collections::Mongo::PrimaryKeyTransform
      end # it
    end # context
  end # describe

  describe '#transform=' do
    let(:new_transform) do
      Bronze::Transforms::AttributesTransform.new(entity_class)
    end # let

    it 'should chain the transform with a primary key transform' do
      instance.send :transform=, new_transform

      result = instance.transform

      expect(result).to be_a Bronze::Transforms::TransformChain

      transforms = instance.transform.transforms
      expect(transforms.count).to be 2
      expect(transforms.first).to be new_transform
      expect(transforms.last).
        to be_a Patina::Collections::Mongo::PrimaryKeyTransform
    end # it

    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new data, transform }

      it 'should chain the transform with a primary key transform' do
        instance.send :transform=, new_transform

        result = instance.transform

        expect(result).to be_a Bronze::Transforms::TransformChain

        transforms = instance.transform.transforms
        expect(transforms.count).to be 2
        expect(transforms.first).to be new_transform
        expect(transforms.last).
          to be_a Patina::Collections::Mongo::PrimaryKeyTransform
      end # it

      describe 'with nil' do
        it 'should set the transform to the default' do
          instance.send :transform=, nil

          expect(instance.transform).
            to be_a Patina::Collections::Mongo::PrimaryKeyTransform
        end # it
      end # describe
    end # context
  end # describe

  describe '#update' do
    let(:id)         { '1' }
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    with_params :id => nil do
      include_examples 'should fail with error',
        described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
    end # with_params

    with_params :id => 0 do
      include_examples 'should fail with error',
        described_class::Errors::RECORD_NOT_FOUND, :id => 0
    end # with_params

    with_params :attributes => nil do
      include_examples 'should fail with error',
        described_class::Errors::DATA_MISSING
    end # with_params

    invalid_attributes = Struct.new(:id).new
    with_params :attributes => invalid_attributes do
      include_examples 'should fail with error',
        described_class::Errors::DATA_INVALID,
        :attributes => invalid_attributes
    end # with_params

    wrap_context 'when the collection contains many items' do
      with_params :id => nil do
        include_examples 'should fail with error',
          described_class::Errors::PRIMARY_KEY_MISSING, :key => :id
      end # with_params

      with_params :id => 0 do
        include_examples 'should fail with error',
          described_class::Errors::RECORD_NOT_FOUND, :id => 0
      end # with_params

      with_params :attributes => nil do
        include_examples 'should fail with error',
          described_class::Errors::DATA_MISSING
      end # with_params

      invalid_attributes = Struct.new(:id).new
      with_params :attributes => invalid_attributes do
        include_examples 'should fail with error',
          described_class::Errors::DATA_INVALID,
          :attributes => invalid_attributes
      end # with_params

      with_params :attributes => { :id => 1 } do
        include_examples 'should fail with error',
          described_class::Errors::PRIMARY_KEY_INVALID,
          :key      => :id,
          :expected => 1,
          :received => '1'
      end # with_params
    end # wrap_context
  end # describe
end # describe
