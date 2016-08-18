# spec/patina/repositories/simple/collection_spec.rb

require 'bronze/repositories/collection_examples'
require 'patina/repositories/simple/collection'
require 'patina/repositories/simple/query'

RSpec.describe Patina::Repositories::Simple::Collection do
  include Spec::Repositories::CollectionExamples

  shared_context 'when the collection contains many items' do
    let(:data) do
      {
        '1' => { :id => '1', :title => 'The Fellowship of the Ring' },
        '2' => { :id => '2', :title => 'The Two Towers' },
        '3' => { :id => '3', :title => 'The Return of the King' }
      } # end hash
    end # let

    before(:example) do
      data.each_value do |attributes|
        instance.insert attributes
      end # each
    end # before example
  end # shared_context

  shared_examples 'should fail with message' do |message = nil|
    let(:error_message) do
      msg = defined?(super()) ? super() : message

      msg.is_a?(Proc) ? instance_exec(&msg) : msg
    end # let

    it 'should fail with message' do
      result = nil
      errors = nil

      expect { result, errors = perform_action }.
        not_to change(instance.all, :to_a)

      expect(result).to be false
      expect(errors).to contain_exactly error_message
    end # it
  end # shared_examples

  let(:instance)    { described_class.new }
  let(:query_class) { Patina::Repositories::Simple::Query }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  describe '#all' do
    it 'should return a query' do
      query = instance.all

      expect(query).to be_a query_class
      expect(query.to_a).to be == []
    end # it

    wrap_context 'when the collection contains many items' do
      it 'should return a query' do
        query = instance.all

        expect(query).to be_a query_class
        expect(query.to_a).to contain_exactly(*data.values)
      end # it
    end # wrap_context
  end # describe

  describe '#count' do
    it { expect(instance.count).to be 0 }

    wrap_context 'when the collection contains many items' do
      it { expect(instance.count).to be == data.count }
    end # wrap_context
  end # describe

  describe '#delete' do
    shared_examples 'should not delete an item' do
      it 'should not delete an item' do
        result = nil
        errors = nil

        expect { result, errors = instance.delete id }.
          not_to change(instance, :count)

        expect(result).to be false
        expect(errors).to contain_exactly error_message
      end # it
    end # shared_examples

    def perform_action
      instance.delete id
    end # method perform_action

    describe 'with nil' do
      let(:id) { nil }

      include_examples 'should fail with message', "id can't be nil"
    end # describe

    describe 'with a missing id' do
      let(:id) { '0' }

      include_examples 'should fail with message',
        ->() { "item not found with id #{id.inspect}" }
    end # describe

    wrap_context 'when the collection contains many items' do
      describe 'with nil' do
        let(:id) { nil }

        include_examples 'should fail with message', "id can't be nil"
      end # describe

      describe 'with a missing id' do
        let(:id) { '0' }

        include_examples 'should fail with message',
          ->() { "item not found with id #{id.inspect}" }
      end # describe

      describe 'with a valid id' do
        let(:id) { '1' }

        it 'should delete the item' do
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
    shared_examples 'should insert the item' do
      it 'should insert an item' do
        result = nil
        errors = nil

        expect { result, errors = instance.insert attributes }.
          to change(instance, :count).by(1)

        expect(result).to be true
        expect(errors).to be == []

        item = instance.all.to_a.last

        expect(item).to be == attributes
      end # it
    end # shared_examples

    def perform_action
      instance.insert attributes
    end # method perform_action

    describe 'with nil' do
      let(:attributes) { nil }

      include_examples 'should fail with message', "data can't be nil"
    end # describe

    describe 'with an Object' do
      let(:attributes) { Object.new }

      include_examples 'should fail with message', 'data must be a Hash'
    end # describe

    describe 'with an empty Hash' do
      let(:attributes) { {} }

      include_examples 'should fail with message', "id can't be nil"
    end # describe

    describe 'with an attributes Hash with a missing id' do
      let(:attributes) { { :title => 'The Hobbit' } }

      include_examples 'should fail with message', "id can't be nil"
    end # describe

    describe 'with an attributes Hash' do
      let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

      include_examples 'should insert the item'
    end # describe

    wrap_context 'when the collection contains many items' do
      describe 'with nil' do
        let(:attributes) { nil }

        include_examples 'should fail with message', "data can't be nil"
      end # describe

      describe 'with an Object' do
        let(:attributes) { Object.new }

        include_examples 'should fail with message', 'data must be a Hash'
      end # describe

      describe 'with an empty Hash' do
        let(:attributes) { {} }

        include_examples 'should fail with message', "id can't be nil"
      end # describe

      describe 'with an attributes Hash with a missing id' do
        let(:attributes) { { :title => 'The Hobbit' } }

        include_examples 'should fail with message', "id can't be nil"
      end # describe

      describe 'with an attributes Hash with an existing id' do
        let(:attributes) { { :id => '1', :title => 'The Hobbit' } }

        include_examples 'should fail with message', 'id already exists'
      end # describe

      describe 'with an attributes Hash with a new id' do
        let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

        include_examples 'should insert the item'
      end # describe
    end # wrap_context
  end # describe

  describe '#update' do
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    describe 'with nil' do
      let(:id) { nil }

      include_examples 'should fail with message', "id can't be nil"
    end # describe

    describe 'with a missing id' do
      let(:id) { '0' }

      include_examples 'should fail with message',
        ->() { "item not found with id #{id.inspect}" }
    end # describe

    wrap_context 'when the collection contains many items' do
      describe 'with nil' do
        let(:id) { nil }

        include_examples 'should fail with message', "id can't be nil"
      end # describe

      describe 'with a missing id' do
        let(:id) { '0' }

        include_examples 'should fail with message',
          ->() { "item not found with id #{id.inspect}" }
      end # describe

      describe 'with a valid id and a missing attributes hash' do
        let(:id)         { '1' }
        let(:attributes) { nil }

        include_examples 'should fail with message', "data can't be nil"
      end # describe

      describe 'with a valid id and an invalid attributes hash' do
        let(:id)         { '1' }
        let(:attributes) { Object.new }

        include_examples 'should fail with message', 'data must be a Hash'
      end # describe

      describe 'with a valid id and an attributes hash with non-matching id' do
        let(:id)         { '1' }
        let(:attributes) { { :id => 1 } }

        include_examples 'should fail with message', 'data id must match id'
      end # describe

      describe 'with a valid id and a valid attributes hash' do
        let(:id)         { '3' }
        let(:attributes) { { :title => 'The Revenge of the Sith' } }

        it 'should update the item' do
          result = nil
          errors = nil

          expect { result, errors = instance.update id, attributes }.
            not_to change(instance, :count)

          expect(result).to be true
          expect(errors).to be == []

          item = data[id]
          attributes.each do |key, value|
            expect(item[key]).to be == value
          end # each
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
