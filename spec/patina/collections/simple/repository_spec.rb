# spec/patina/collections/simple/repository_spec.rb

require 'bronze/entities/primary_keys/uuid'
require 'bronze/entities/transforms/entity_transform'
require 'bronze/transforms/copy_transform'
require 'bronze/transforms/identity_transform'

require 'patina/collections/simple/collection'
require 'patina/collections/simple/repository'

RSpec.describe Patina::Collections::Simple::Repository do
  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  let(:instance) { described_class.new }

  describe '#collection' do
    shared_examples 'should return a collection' do
      it 'should return a collection' do
        books = instance.collection(collection_type)

        expect(books).to be_a Patina::Collections::Simple::Collection
        expect(books.name).to be == collection_name
        expect(books.repository).to be instance
        expect(books.transform).to be_a transform_class
      end # it

      describe 'with a transform' do
        let(:transform) { Bronze::Transforms::IdentityTransform.new }

        it 'should set the transform' do
          books = instance.collection(collection_type, transform)

          expect(books.transform).to be transform
        end # it
      end # describe
    end # shared_examples

    it { expect(instance).to respond_to(:collection).with(1..2).arguments }

    describe 'with a collection name' do
      let(:collection_type) { :books }
      let(:collection_name) { 'books' }
      let(:transform_class) { Bronze::Transforms::CopyTransform }

      include_examples 'should return a collection'

      it 'should normalize the collection name' do
        books = instance.collection('RareBook')

        expect(books.name).to be == 'rare_books'
      end # it

      context 'when a collection exists with the given name' do
        let!(:collection) { instance.collection(collection_type) }
        let(:attributes)  { { :id => '0', :title => 'Der Lied der Erlking' } }

        it 'should return a collection with the same data' do
          books = instance.collection(collection_type)

          expect { books.insert attributes }.
            to change(collection, :count).
            by(1)
        end # it
      end # context
    end # describe

    describe 'with an entity class' do
      example_class 'Spec::RareBook', Bronze::Entities::Entity do |klass|
        klass.send :include, Bronze::Entities::PrimaryKeys::Uuid

        klass.define_primary_key :id

        klass.attribute :title, String
      end # example_class

      let(:collection_type) { Spec::RareBook }
      let(:collection_name) { 'spec-rare_books' }
      let(:transform_class) { Bronze::Entities::Transforms::EntityTransform }

      include_examples 'should return a collection'

      context 'when a collection exists with the given name' do
        let!(:collection) { instance.collection(collection_type) }
        let(:attributes)  { { :id => '0', :title => 'Der Lied der Erlking' } }
        let(:entity)      { Spec::RareBook.new(attributes) }

        it 'should return a collection with the same data' do
          books = instance.collection(collection_type)

          expect { books.insert entity }.
            to change(collection, :count).
            by(1)
        end # it
      end # context
    end # describe
  end # describe
end # describe
