# spec/bronze/collections/collection_examples.rb

require 'bronze/collections/null_query'
require 'bronze/collections/querying_examples'
require 'bronze/entities/entity'
require 'bronze/errors/error'
require 'bronze/transforms/attributes_transform'
require 'bronze/transforms/copy_transform'

module Spec::Collections
  module CollectionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Collections::QueryingExamples

    def self.included other
      super

      other.extend ClassMethods
    end # class method included

    module ClassMethods
      def with_params params, &block
        tools = ::SleepingKingStudios::Tools::ArrayTools
        desc  = tools.humanize_list(params.to_a) do |attribute, value|
          ":#{attribute} => #{value.inspect}"
        end # humanize_list

        describe "with #{desc}" do
          params.each do |key, value|
            let(key) { value }
          end # each

          instance_exec(&block)
        end # describe
      end # method with_params
    end # module

    shared_context 'when the collection contains many items' do
      let(:data) do
        [
          {
            :id     => '1',
            :title  => 'The Fellowship of the Ring',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '2',
            :title  => 'The Two Towers',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '3',
            :title  => 'The Return of the King',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '4',
            :title  => 'A Princess of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
          {
            :id     => '5',
            :title  => 'The Gods of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
          {
            :id     => '6',
            :title  => 'The Warlord of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
        ] # end array
      end # let
    end # shared_context

    shared_context 'when a transform is set' do
      let(:transform_class) do
        Class.new(Bronze::Transforms::AttributesTransform) do
          attributes :title, :author
        end # class
      end # let
      let(:transform) do
        transform_class.new(entity_class)
      end # let

      before(:example) { instance.send :transform=, transform }
    end # shared_context

    shared_examples 'should implement the Collection interface' do
      describe '#count' do
        it { expect(instance).to respond_to(:count).with(0).arguments }
      end # describe

      describe '#delete' do
        it { expect(instance).to respond_to(:delete).with(1).argument }
      end # describe

      describe '#each' do
        it 'should define the method' do
          expect(instance).to respond_to(:each).with(0).arguments.and_a_block
        end # it
      end # describe

      describe '#exists?' do
        it { expect(instance).to respond_to(:exists?).with(0).arguments }
      end # describe

      describe '#find' do
        it { expect(instance).to respond_to(:find).with(1).argument }
      end # describe

      describe '#insert' do
        it { expect(instance).to respond_to(:insert).with(1).argument }
      end # describe

      describe '#limit' do
        it { expect(instance).to respond_to(:limit).with(1).argument }
      end # describe

      describe '#matching' do
        it { expect(instance).to respond_to(:matching).with(1).argument }
      end # describe

      describe '#name' do
        it { expect(instance).to respond_to(:name).with(0).arguments }
      end # describe

      describe '#name=' do
        it { expect(instance).not_to respond_to(:name=) }

        it { expect(instance).to respond_to(:name=, true).with(1).argument }
      end # describe

      describe '#none' do
        it { expect(instance).to respond_to(:none).with(0).arguments }
      end # describe

      describe '#one' do
        it { expect(instance).to respond_to(:one).with(0).arguments }
      end # describe

      describe '#pluck' do
        it { expect(instance).to respond_to(:pluck).with(1).argument }
      end # describe

      describe '#query' do
        it { expect(instance).to respond_to(:query).with(0).arguments }
      end # describe

      describe '#repository' do
        it { expect(instance).to respond_to(:repository).with(0).arguments }
      end # describe

      describe '#repository=' do
        it { expect(instance).not_to respond_to(:repository=) }

        it 'should define the private writer' do
          expect(instance).to respond_to(:repository=, true).with(1).argument
        end # it
      end # describe

      describe '#to_a' do
        it { expect(instance).to respond_to(:to_a).with(0).arguments }
      end # describe

      describe '#transform' do
        include_examples 'should have reader', :transform
      end # describe

      describe '#update' do
        it { expect(instance).to respond_to(:update).with(2).arguments }
      end # describe
    end # shared_examples

    shared_examples 'should fail with error' do |expectation, *rest|
      if expectation.is_a?(Hash)
        # include_examples 'should fail with error', :id => [:not_found, 0]
        key = expectation.keys.first
        error_type, *error_params = *Array(expectation[key])
        error_nesting = Array(key)
      else
        # include_examples 'should fail with error', :read_only
        error_nesting = []
        error_type    = expectation
        error_params  = rest
      end # if

      it "should fail with error :#{error_type}" do
        result = nil
        errors = nil

        expect { result, errors = perform_action }.
          not_to change(instance.query, :to_a)

        expect(result).to be false

        expected = Bronze::Errors::Error.new(
          error_nesting, error_type, error_params
        ) # end expected
        expect(errors.to_a).to include(expected)
      end # it
    end # shared_examples

    shared_examples 'should delete the item' do
      it 'should delete the item' do
        result = nil
        errors = nil

        expect { result, errors = instance.delete id }.
          to change(instance, :count).by(-1)

        expect(result).to be true
        expect(errors).to be == []

        item = instance.query.to_a.find { |hsh| hsh[:id] == id }
        expect(item).to be nil
      end # it
    end # shared_examples

    shared_examples 'should insert the item' do
      it 'should insert the item' do
        result = nil
        errors = nil

        expect { result, errors = instance.insert entity }.
          to change(instance, :count).by(1)

        expect(result).to be true
        expect(errors).to be == []

        item = instance.query.to_a.last
        hsh  = item.is_a?(Hash) ? item : item.attributes

        expect(hsh).to be >= attributes
      end # it
    end # shared_examples

    shared_examples 'should update the item' do
      it 'should update the item' do
        result = nil
        errors = nil

        expect { result, errors = instance.update id, entity }.
          not_to change(instance, :count)

        expect(result).to be true
        expect(errors).to be == []

        item = find_item(id)
        hsh  = item.is_a?(Hash) ? item : item.attributes

        attributes.each do |key, value|
          expect(hsh[key]).to be == value
        end # each
      end # it
    end # shared_examples

    shared_examples 'should implement the Collection methods' do
      let(:entity_class) do
        Class.new(Bronze::Entities::Entity) do
          attribute :title,  String
          attribute :author, String
        end # class
      end # let

      include_examples 'should run queries against the datastore'

      describe '#delete' do
        wrap_context 'when the collection contains many items' do
          describe 'with a valid id' do
            let(:id) { '1' }

            include_examples 'should delete the item'
          end # describe
        end # wrap_context
      end # describe

      describe '#find' do
        it { expect(instance.find '0').to be nil }

        wrap_context 'when the collection contains many items' do
          describe 'with an invalid id' do
            it { expect(instance.find '0').to be nil }
          end # describe

          describe 'with a valid id' do
            let(:id) { '1' }

            it { expect(instance.find id).to be == find_item(id) }

            wrap_context 'when a transform is set' do
              it { expect(instance.find id).to be == find_item(id) }
            end # wrap_context
          end # describe
        end # wrap_context
      end # describe

      describe '#insert' do
        let(:entity) { attributes }

        describe 'with an attributes Hash' do
          let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

          include_examples 'should insert the item'

          it 'should not allow the caller to mutate the collection' do
            tools = ::SleepingKingStudios::Tools::ObjectTools

            instance.insert attributes

            expect { attributes[:title] = 'Bored of the Rings' }.
              not_to change { tools.deep_dup(instance.query.to_a) }
          end # it
        end # describe

        wrap_context 'when a transform is set' do
          let(:entity) { entity_class.new(attributes) }

          describe 'with an entity' do
            let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

            include_examples 'should insert the item'
          end # describe
        end # wrap_context

        wrap_context 'when the collection contains many items' do
          describe 'with an attributes Hash with a new id' do
            let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

            include_examples 'should insert the item'
          end # describe

          wrap_context 'when a transform is set' do
            let(:entity) { entity_class.new(attributes) }

            describe 'with an entity with a new id' do
              let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

              include_examples 'should insert the item'
            end # describe
          end # wrap_context
        end # wrap_context
      end # describe

      describe '#name' do
        it { expect(instance.name).to be nil }
      end # describe

      describe '#name=' do
        let(:name) { 'tomes' }

        it 'should set the name' do
          expect { instance.send :name=, name }.
            to change(instance, :name).
            to be == name
        end # it
      end # describe

      describe '#query' do
        include_examples 'should return a query' do
          let(:query) { instance.query }
        end # include_examples
      end # describe

      describe '#transform' do
        let(:default_transform_class) do
          Bronze::Transforms::CopyTransform
        end # let

        it { expect(instance.transform).to be_a default_transform_class }

        wrap_context 'when a transform is set' do
          it { expect(instance.transform).to be == transform }
        end # wrap_context
      end # describe

      describe '#transform=' do
        let(:transform) do
          Bronze::Transforms::AttributesTransform.new(entity_class)
        end # let

        it 'should set the transform' do
          expect { instance.send :transform=, transform }.
            to change(instance, :transform).
            to be transform
        end # it

        wrap_context 'when a transform is set' do
          let(:default_transform_class) do
            Bronze::Transforms::CopyTransform
          end # let

          describe 'with nil' do
            it 'should clear the transform' do
              expect { instance.send :transform=, nil }.
                to change(instance, :transform).
                to be_a default_transform_class
            end # it
          end # describe
        end # wrap_context
      end # describe

      describe '#update' do
        let(:entity) { attributes }

        wrap_context 'when the collection contains many items' do
          describe 'with a valid id and a valid attributes hash' do
            let(:id)         { '3' }
            let(:attributes) { { :title => 'The Revenge of the Sith' } }

            include_examples 'should update the item'
          end # describe

          wrap_context 'when a transform is set' do
            let(:entity) { entity_class.new(attributes.merge(:id => id)) }

            describe 'with a valid id and a valid attributes hash' do
              let(:id)         { '3' }
              let(:attributes) { { :title => 'The Revenge of the Sith' } }

              include_examples 'should update the item'
            end # describe
          end # wrap_context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
