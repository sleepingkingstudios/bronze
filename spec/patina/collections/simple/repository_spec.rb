# spec/patina/collections/simple/repository_spec.rb

require 'patina/collections/simple/collection'
require 'patina/collections/simple/repository'

RSpec.describe Patina::Collections::Simple::Repository do
  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  let(:instance) { described_class.new }

  describe '#collection' do
    let(:collection_name) { :books }

    it { expect(instance).to respond_to(:collection).with(1..2).arguments }

    it 'should return a collection' do
      books = instance.collection(collection_name)

      expect(books).to be_a Patina::Collections::Simple::Collection
      expect(books.name).to be == collection_name
      expect(books.repository).to be instance
    end # it

    it 'should normalize the collection name' do
      books = instance.collection('RareBook')

      expect(books.name).to be == :rare_books
    end # it

    describe 'with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }

      it 'should set the transform' do
        books = instance.collection(collection_name, transform)

        expect(books.transform).to be transform
      end # it
    end # describe

    context 'when a collection exists with the given name' do
      let!(:collection) { instance.collection(collection_name) }
      let(:attributes) { { :id => '0', :title => 'Der Lied der Erlking' } }

      it 'should return a collection with the same data' do
        books = instance.collection(collection_name)

        expect { books.insert attributes }.
          to change(collection, :count).
          by(1)
      end # it
    end # context
  end # describe
end # describe
