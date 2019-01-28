# spec/bronze/collections/collection_examples.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/collections/null_query'
require 'bronze/collections/querying_examples'
require 'bronze/entities/entity'
require 'bronze/errors'
require 'bronze/transforms/attributes_transform'
require 'bronze/transforms/copy_transform'

module Spec::Collections
  module CollectionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    include Spec::Collections::QueryingExamples

    module ClassMethods
      def with_params params, &block
        tools = ::SleepingKingStudios::Tools::ArrayTools
        desc  = tools.humanize_list(params.to_a) do |attribute, value|
          ":#{attribute} => #{value.inspect}"
        end # humanize_list

        describe "with #{desc}" do # rubocop:disable RSpec/EmptyExampleGroup
          params.each do |key, value|
            let(key) { value }
          end # each

          instance_exec(&block)
        end # describe
      end # method with_params
    end # module

    shared_context 'when the collection contains many items' do
      let(:raw_data) do
        [
          {
            'id'     => '1',
            'title'  => 'The Fellowship of the Ring',
            'author' => 'J.R.R. Tolkien'
          }, # end hash
          {
            'id'     => '2',
            'title'  => 'The Two Towers',
            'author' => 'J.R.R. Tolkien'
          }, # end hash
          {
            'id'     => '3',
            'title'  => 'The Return of the King',
            'author' => 'J.R.R. Tolkien'
          }, # end hash
          {
            'id'     => '4',
            'title'  => 'A Princess of Mars',
            'author' => 'Edgar Rice Burroughs'
          }, # end hash
          {
            'id'     => '5',
            'title'  => 'The Gods of Mars',
            'author' => 'Edgar Rice Burroughs'
          }, # end hash
          {
            'id'     => '6',
            'title'  => 'The Warlord of Mars',
            'author' => 'Edgar Rice Burroughs'
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

      describe '#delete_all' do
        it { expect(instance).to respond_to(:delete_all).with(0).arguments }

        it { expect(instance).to alias_method(:delete_all).as(:clear) }
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

    shared_examples 'should fail with error' do |expectation, **params|
      if expectation.is_a?(Hash)
        # include_examples 'should fail with error', :id => [:not_found, 0]
        key = expectation.keys.first
        error_type, *error_params = *Array(expectation[key])
        error_nesting = Array(key)
      else
        # include_examples 'should fail with error', :read_only
        error_nesting = []
        error_type    = expectation
        error_params  = params
      end # if

      it "should fail with error :#{error_type}" do
        result = nil
        errors = nil

        expect { result, errors = perform_action }.
          not_to change(instance.query, :to_a)

        expect(result).to be false

        expected_error = {
          :type   => error_type,
          :params => error_params,
          :path   => error_nesting
        } # end expected_error

        expect(errors.to_a).to include(expected_error)
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

        hash_tools = SleepingKingStudios::Tools::HashTools
        item       = instance.query.to_a.last
        raw        = item.is_a?(Hash) ? item : item.attributes
        hsh        = hash_tools.convert_keys_to_symbols(raw)

        expect(hsh).to be >= attributes
      end # it
    end # shared_examples

    shared_examples 'should update the item' do
      it 'should update the item' do
        tools  = SleepingKingStudios::Tools::Toolbelt.instance
        result = nil
        errors = nil

        expect { result, errors = instance.update id, entity }.
          not_to change(instance, :count)

        expect(result).to be true
        expect(errors).to be == []

        item = find_item(id)
        hsh  = item.is_a?(Hash) ? item : item.attributes
        hsh  = tools.hash.convert_keys_to_strings(hsh)

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

      describe '#clone' do
        let(:copy_transform_class) do
          Class.new(Bronze::Transforms::AttributesTransform) do
            attributes :title, :author
          end # class
        end # let
        let(:copy_transform) do
          copy_transform_class.new(entity_class)
        end # let
        let(:copy) { instance.clone }

        it 'should return a copy of the collection' do
          expect(copy.to_a).to be == instance.to_a

          expect { copy.insert :id => '0', :title => 'The Hobbit' }.
            to change(instance, :count).by(1)

          expect { copy.send(:transform=, copy_transform) }.
            not_to change(instance, :transform)
        end # it

        wrap_context 'when the collection contains many items' do
          it 'should return a copy of the collection' do
            expect(copy.to_a).to be == instance.to_a

            expect { copy.insert :id => '0', :title => 'The Hobbit' }.
              to change(instance, :count).by(1)

            expect { copy.send(:transform=, copy_transform) }.
              not_to change(instance, :transform)
          end # it
        end # wrap_context
      end # describe

      describe '#delete' do
        wrap_context 'when the collection contains many items' do
          describe 'with a valid id' do
            let(:id) { '1' }

            include_examples 'should delete the item'
          end # describe
        end # wrap_context
      end # describe

      describe '#delete_all' do
        it 'should not change the collection' do
          result = nil
          errors = nil

          expect { result, errors = instance.delete_all }.
            not_to change(instance, :count)

          expect(result).to be true
          expect(errors).to be == []

          expect(instance.query.to_a).to be == []
        end # it

        wrap_context 'when the collection contains many items' do
          it 'should not clear the collection' do
            result = nil
            errors = nil

            expect { result, errors = instance.delete_all }.
              to change(instance, :count).
              to be 0

            expect(result).to be true
            expect(errors).to be == []

            expect(instance.query.to_a).to be == []
          end # it
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

      describe '#update' do
        let(:entity) { attributes }

        wrap_context 'when the collection contains many items' do
          describe 'with a valid id and a valid attributes hash' do
            let(:id)         { '3' }
            let(:attributes) { { 'title' => 'The Revenge of the Sith' } }

            include_examples 'should update the item'
          end # describe

          wrap_context 'when a transform is set' do
            let(:entity) { entity_class.new(attributes.merge('id' => id)) }

            describe 'with a valid id and a valid attributes hash' do
              let(:id)         { '3' }
              let(:attributes) { { 'title' => 'The Revenge of the Sith' } }

              include_examples 'should update the item'
            end # describe
          end # wrap_context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
