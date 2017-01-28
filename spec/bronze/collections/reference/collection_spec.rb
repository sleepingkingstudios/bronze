# spec/bronze/collections/reference/collection_spec.rb

require 'bronze/collections/collection_examples'
require 'bronze/collections/reference/collection'
require 'bronze/collections/reference/query'
require 'bronze/transforms/identity_transform'

RSpec.describe Bronze::Collections::Reference::Collection do
  include Spec::Collections::CollectionExamples

  let(:raw_data)    { [] }
  let(:data)        { raw_data }
  let(:instance)    { described_class.new data }
  let(:query_class) { Bronze::Collections::Reference::Query }

  def find_item id
    items = instance.to_a

    if items.empty?
      nil
    elsif items.first.is_a?(Hash)
      items.find { |hsh| hsh[:id] == id }
    else
      items.find { |obj| obj.id == id }
    end # if-elsif-else
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  include_examples 'should implement the Collection methods'

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
end # describe
