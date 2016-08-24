# spec/bronze/repositories/collection_examples.rb

require 'bronze/entities/entity'
require 'bronze/entities/transforms/attributes_transform'
require 'bronze/entities/transforms/copy_transform'

module Spec::Repositories
  module CollectionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    def self.included other
      super

      other.extend ClassMethods
    end # class method included

    module ClassMethods
      def validate_params desc, message: nil, **params
        tools      = ::SleepingKingStudios::Tools::ArrayTools
        params_ary = params.map { |key, value| ":#{key} => #{value.inspect}" }
        params_str = "with #{tools.humanize_list(params_ary)}"

        describe params_str do
          params.each do |key, value|
            let(key) { value }
          end # each

          include_examples 'should fail with message', message || desc
        end # describe
      end # class method validate
    end # module

    shared_context 'when many items are defined for the collection' do
      let(:data) do
        [
          { :id => '1', :title => 'The Fellowship of the Ring' },
          { :id => '2', :title => 'The Two Towers' },
          { :id => '3', :title => 'The Return of the King' }
        ] # end array
      end # let
    end # shared_context

    shared_context 'when the collection contains many items' do
      include_context 'when many items are defined for the collection'
    end # shared_context

    shared_context 'when a transform is set' do
      let(:transform_class) do
        Class.new(Bronze::Entities::Transforms::AttributesTransform) do
          attributes :title, :author
        end # class
      end # let
      let(:transform) do
        transform_class.new(entity_class)
      end # let

      before(:example) { instance.send :transform=, transform }
    end # shared_context

    shared_examples 'should implement the Collection interface' do
      describe '#all' do
        it { expect(instance).to respond_to(:all).with(0).arguments }
      end # describe

      describe '#count' do
        it { expect(instance).to respond_to(:count).with(0).arguments }
      end # describe

      describe '#delete' do
        it { expect(instance).to respond_to(:delete).with(1).argument }
      end # describe

      describe '#insert' do
        it { expect(instance).to respond_to(:insert).with(1).argument }
      end # describe

      describe '#transform' do
        include_examples 'should have reader', :transform
      end # describe

      describe '#update' do
        it { expect(instance).to respond_to(:update).with(2).arguments }
      end # describe
    end # shared_examples

    shared_examples 'should fail with message' do |message = nil|
      let(:error_message) do
        msg = defined?(super()) ? super() : message

        msg.is_a?(Proc) ? instance_exec(&msg) : msg
      end # let

      desc = 'should fail with message'
      desc << ' ' << message.inspect if message

      it desc do
        result = nil
        errors = nil

        expect { result, errors = perform_action }.
          not_to change(instance.all, :to_a)

        expect(result).to be false
        expect(errors).to contain_exactly error_message
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

        item = instance.all.to_a.find { |hsh| hsh[:id] == id }
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

        item = instance.all.to_a.last
        hsh  = item.is_a?(Hash) ? item : item.attributes

        expect(hsh).to be == attributes
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

      describe '#all' do
        it 'should return a query' do
          query = instance.all

          expect(query).to be_a query_class
          expect(query.to_a).to be == []
        end # it

        wrap_context 'when the collection contains many items' do
          let(:expected) { data }

          it 'should return a query' do
            query = instance.all

            expect(query).to be_a query_class
            expect(query.to_a).to contain_exactly(*expected)
          end # it

          it 'should not allow the caller to mutate the collection' do
            tools = ::SleepingKingStudios::Tools::ObjectTools

            hsh = { :id => '0', :title => 'The Hobbit' }
            expect { instance.all.to_a << hsh }.
              not_to change { tools.deep_dup(instance.all.to_a) }

            expect { instance.all.to_a.last[:title] = 'Revenge of the Sith' }.
              not_to change { tools.deep_dup(instance.all.to_a) }
          end # it

          wrap_context 'when a transform is set' do
            let(:expected) { super().map { |hsh| transform.denormalize hsh } }

            it 'should return a query' do
              query = instance.all

              expect(query).to be_a query_class
              expect(query.to_a).to contain_exactly(*expected)
            end # it
          end # wrap_context
        end # wrap_context
      end # describe

      describe '#count' do
        it { expect(instance.count).to be 0 }

        wrap_context 'when the collection contains many items' do
          it { expect(instance.count).to be == data.count }
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

      describe '#insert' do
        let(:entity) { attributes }

        describe 'with an attributes Hash' do
          let(:attributes) { { :id => '0', :title => 'The Hobbit' } }

          include_examples 'should insert the item'

          it 'should not allow the caller to mutate the collection' do
            tools = ::SleepingKingStudios::Tools::ObjectTools

            instance.insert attributes

            expect { attributes[:title] = 'Bored of the Rings' }.
              not_to change { tools.deep_dup(instance.all.to_a) }
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

      describe '#transform' do
        let(:default_transform_class) do
          Bronze::Entities::Transforms::CopyTransform
        end # let

        it { expect(instance.transform).to be_a default_transform_class }

        wrap_context 'when a transform is set' do
          it { expect(instance.transform).to be == transform }
        end # wrap_context
      end # describe

      describe '#transform=' do
        let(:transform) do
          Bronze::Entities::Transforms::AttributesTransform.new(entity_class)
        end # let

        it 'should set the transform' do
          expect { instance.send :transform=, transform }.
            to change(instance, :transform).
            to be transform
        end # it

        wrap_context 'when a transform is set' do
          let(:default_transform_class) do
            Bronze::Entities::Transforms::CopyTransform
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
