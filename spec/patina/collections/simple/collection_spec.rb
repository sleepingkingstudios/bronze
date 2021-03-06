# spec/patina/collections/simple/collection_spec.rb

require 'bronze/collections/collection_examples'
require 'bronze/transforms/identity_transform'
require 'patina/collections/simple/collection'
require 'patina/collections/simple/query'

RSpec.describe Patina::Collections::Simple::Collection do
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
  include Spec::Collections::CollectionExamples

  let(:raw_data)    { [] }
  let(:data)        { raw_data }
  let(:instance)    { described_class.new data }
  let(:query_class) { Patina::Collections::Simple::Query }

  def find_item id
    items = instance.query.to_a

    if items.empty?
      nil
    elsif items.first.is_a?(Hash)
      items.find { |hsh| hsh['id'] == id }
    else
      items.find { |obj| obj.id == id }
    end # if-elsif-else
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  include_examples 'should implement the Collection methods'

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

  describe '#transform' do
    let(:default_transform_class) { Bronze::Transforms::CopyTransform }

    it { expect(instance.transform).to be_a default_transform_class }

    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new data, transform }

      it { expect(instance.transform).to be transform }
    end # context
  end # describe

  describe '#transform=' do
    let(:new_transform) do
      Bronze::Transforms::AttributesTransform.new(entity_class)
    end # let

    it 'should set the transform' do
      instance.send :transform=, new_transform

      expect(instance.transform).to be new_transform
    end # it

    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new data, transform }

      it 'should set the transform' do
        instance.send :transform=, new_transform

        expect(instance.transform).to be new_transform
      end # it

      describe 'with nil' do
        it 'should set the transform to the default' do
          instance.send :transform=, nil

          expect(instance.transform).
            to be_a Bronze::Transforms::CopyTransform
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
