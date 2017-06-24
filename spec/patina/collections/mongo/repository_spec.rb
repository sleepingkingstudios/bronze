# spec/patina/collections/mongo/repository_spec.rb

require 'bronze/entities/transforms/entity_transform'
require 'bronze/transforms/copy_transform'
require 'bronze/transforms/identity_transform'

require 'patina/collections/mongo/collection'
require 'patina/collections/mongo/repository'

RSpec.describe Patina::Collections::Mongo::Repository do
  let(:mongo_client) { Spec.mongo_client }
  let(:instance)     { described_class.new mongo_client }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).arguments }
  end # describe

  describe '#collection' do
    shared_examples 'should return a collection' do
      it 'should return a collection' do
        books = instance.collection(collection_type)

        expect(books).to be_a Patina::Collections::Mongo::Collection
        expect(books.name).to be == collection_name
        expect(books.repository).to be instance

        if transform_class
          transform_chain = books.transform
          transforms      = transform_chain.transforms
          expect(transform_chain).to be_a Bronze::Transforms::TransformChain
          expect(transforms.count).to be 2
          expect(transforms.first).to be_a transform_class
          expect(transforms.last).
            to be_a Patina::Collections::Mongo::PrimaryKeyTransform
        else
          expect(books.transform).
            to be_a Patina::Collections::Mongo::PrimaryKeyTransform
        end # if-else
      end # it

      describe 'with a transform' do
        let(:transform) { Bronze::Transforms::IdentityTransform.new }

        it 'should set the transform' do
          books = instance.collection(collection_type, transform)

          transform_chain = books.transform
          transforms      = transform_chain.transforms
          expect(transform_chain).to be_a Bronze::Transforms::TransformChain
          expect(transforms.count).to be 2
          expect(transforms.first).to be transform
          expect(transforms.last).
            to be_a Patina::Collections::Mongo::PrimaryKeyTransform
        end # it
      end # describe
    end # shared_examples

    it { expect(instance).to respond_to(:collection).with(1..2).arguments }

    describe 'with a collection name' do
      let(:collection_type) { :books }
      let(:collection_name) { 'books' }
      let(:transform_class) { nil }

      include_examples 'should return a collection'

      it 'should normalize the collection name' do
        books = instance.collection('RareBook')

        expect(books.name).to be == 'rare_books'
        expect(books.mongo_collection).to be == mongo_client['rare_books']
      end # it
    end # describe

    describe 'with an entity class' do
      options = { :base_class => Bronze::Entities::Entity }
      example_class 'Spec::Book', options do |klass|
        klass.send :attribute, :title, String
      end # example_class

      let(:collection_type) { Spec::Book }
      let(:collection_name) { 'spec.books' }
      let(:transform_class) { Bronze::Entities::Transforms::EntityTransform }

      include_examples 'should return a collection'
    end # describe
  end # describe

  describe '#mongo_client' do
    include_examples 'should have reader', :mongo_client, ->() { mongo_client }
  end # describe
end # describe
