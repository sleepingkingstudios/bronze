# spec/bronze/collections/constraints/collection_constraint_spec.rb

require 'bronze/collections/constraints/collection_constraint'
require 'bronze/collections/reference/collection'
require 'bronze/constraints/constraint'

RSpec.describe Bronze::Collections::Constraints::CollectionConstraint do
  let(:described_class) do
    Class.new(Bronze::Constraints::Constraint) do
      include Bronze::Collections::Constraints::CollectionConstraint

      def initialize title
        @title = title
      end # constructor

      attr_reader :title
    end # class
  end # let
  let(:title)      { 'The Lion, The Witch, And The Wardrobe' }
  let(:instance)   { described_class.new title }
  let(:collection) { Bronze::Collections::Reference::Collection.new({}) }

  describe '#collection' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:collection)

      expect(instance).to respond_to(:collection, true).with(0).arguments
    end # it

    it { expect(instance.send :collection).to be nil }
  end # describe

  describe '#with_collection' do
    it { expect(instance).to respond_to(:with_collection).with(1).argument }

    it 'should return a copy with the collection set' do
      copy = instance.with_collection(collection)

      expect(copy).to be_a described_class
      expect(copy.title).to be == title
      expect(copy.send :collection).to be collection

      expect(instance.send :collection).to be nil
    end # it

    describe 'with a block' do
      let(:expected) do
        {
          :collection => collection,
          :title      => title
        } # end hash
      end # let

      it 'should evaluate the block in the context of the copy' do
        value =
          instance.with_collection(collection) do
            # rubocop:disable Style/RedundantSelf
            {
              :collection => self.collection,
              :title      => self.title
            } # end hash
            # rubocop:enable Style/RedundantSelf
          end # with_collection

        expect(value).to be == expected
      end # it
    end # describe
  end # describe
end # describe
