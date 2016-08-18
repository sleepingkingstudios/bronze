# spec/bronze/repositories/reference_collection_spec.rb

require 'bronze/repositories/reference_collection'
require 'bronze/repositories/reference_query'

RSpec.describe Spec::ReferenceCollection do
  shared_context 'when the collection contains many items' do
    let(:data) do
      [
        { :id => 1, :title => 'The Fellowship of the Ring' },
        { :id => 2, :title => 'The Two Towers' },
        { :id => 3, :title => 'The Return of the King' }
      ] # end array
    end # let
  end # shared_context

  let(:name)        { :books }
  let(:data)        { [] }
  let(:instance)    { described_class.new name, data }
  let(:query_class) { Spec::ReferenceQuery }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  describe '#all' do
    it { expect(instance).to respond_to(:all).with(0).arguments }

    it 'should return a query' do
      query = instance.all

      expect(query).to be_a query_class
      expect(query.to_a).to be == []
    end # it

    wrap_context 'when the collection contains many items' do
      it 'should return a query' do
        query = instance.all

        expect(query).to be_a query_class
        expect(query.to_a).to contain_exactly(*data)
      end # it
    end # wrap_context
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it { expect(instance.count).to be 0 }

    wrap_context 'when the collection contains many items' do
      it { expect(instance.count).to be == data.count }
    end # wrap_context
  end # describe

  describe '#delete' do
    it { expect(instance).to respond_to(:delete).with(1).argument }

    it { expect(instance).to alias_method(:delete).as(:destroy) }

    describe 'with an id' do
      let(:id) { 0 }

      it 'should return false and an errors array' do
        result = nil
        errors = nil

        expect { result, errors = instance.delete id }.
          not_to change(instance.all, :to_a)

        expect(result).to be false
        expect(errors).to contain_exactly "item not found with id #{id.inspect}"
      end # it
    end # describe

    wrap_context 'when the collection contains many items' do
      describe 'with an invalid id' do
        let(:id) { 0 }

        it 'should return false and an errors array' do
          result = nil
          errors = nil

          expect { result, errors = instance.delete id }.
            not_to change(instance.all, :to_a)

          expect(result).to be false
          expect(errors).
            to contain_exactly "item not found with id #{id.inspect}"
        end # it
      end # describe

      describe 'with a valid id' do
        let(:id) { 1 }

        it 'should return true and an empty array' do
          result = nil
          errors = nil

          expect { result, errors = instance.delete id }.
            to change(instance, :count).by(-1)

          expect(result).to be true
          expect(errors).to be == []

          item = instance.all.to_a.find { |hsh| hsh[:id] == id }
          expect(item).to be nil
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#insert' do
    it { expect(instance).to respond_to(:insert).with(1).argument }

    it { expect(instance).to alias_method(:insert).as(:create) }

    describe 'with an attributes hash' do
      let(:attributes) { { :id => 0, :title => 'The Hobbit' } }

      it 'should insert the hash in the datastore' do
        result = nil
        errors = nil

        expect { result, errors = instance.insert attributes }.
          to change(instance, :count).by(1)

        expect(result).to be true
        expect(errors).to be == []

        item = instance.all.to_a.last
        expect(item).to be == attributes
      end # it
    end # describe

    wrap_context 'when the collection contains many items' do
      describe 'with an attributes hash' do
        let(:attributes) { { :id => 0, :title => 'The Hobbit' } }

        it 'should insert the hash in the datastore' do
          result = nil
          errors = nil

          expect { result, errors = instance.insert attributes }.
            to change(instance, :count).by(1)

          expect(result).to be true
          expect(errors).to be == []

          item = instance.all.to_a.last
          expect(item).to be == attributes
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#update' do
    it { expect(instance).to respond_to(:update).with(2).arguments }

    describe 'with an id and an attributes hash' do
      let(:id)         { 0 }
      let(:attributes) { { :author => 'J.R.R. Tolkien' } }

      it 'should return false and an errors array' do
        result = nil
        errors = nil

        expect { result, errors = instance.update id, attributes }.
          not_to change(instance.all, :to_a)

        expect(result).to be false
        expect(errors).to contain_exactly "item not found with id #{id.inspect}"
      end # it
    end # describe

    wrap_context 'when the collection contains many items' do
      let(:attributes) { { :author => 'J.R.R. Tolkien' } }

      describe 'with an invalid id and an attributes hash' do
        let(:id) { 0 }

        it 'should return false and an errors array' do
          result = nil
          errors = nil

          expect { result, errors = instance.update id, attributes }.
            not_to change(instance.all, :to_a)

          expect(result).to be false
          expect(errors).
            to contain_exactly "item not found with id #{id.inspect}"
        end # it
      end # describe

      describe 'with a valid id and an attributes hash' do
        let(:id) { 1 }

        it 'should return true and an empty array' do
          result = nil
          errors = nil

          expect { result, errors = instance.update id, attributes }.
            not_to change(instance, :count)

          expect(result).to be true
          expect(errors).to be == []

          item = data.find { |hsh| hsh[:id] == id }
          attributes.each do |key, value|
            expect(item[key]).to be == value
          end # each
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#name' do
    include_examples 'should have reader', :name, ->() { name }
  end # describe
end # describe
