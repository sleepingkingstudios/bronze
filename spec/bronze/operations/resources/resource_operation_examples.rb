# spec/bronze/operations/resources/resource_operation_examples.rb

require 'bronze/entities/transforms/entity_transform'
require 'bronze/transforms/identity_transform'

module Spec::Operations
  module ResourceOperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the ResourceOperation methods' do
      describe '::[]' do
        let(:resource_class) do
          Class.new do
            def self.name
              'Namespace::ResourceClass'
            end # class method name
          end # class
        end # let

        it { expect(described_class).to respond_to(:[]).with(1).argument }

        it 'should create a subclass' do
          subclass = described_class[resource_class]

          expect(subclass).to be_a Class
          expect(subclass).to be < described_class

          expect(subclass.name).
            to be == "#{described_class.name}[#{resource_class.name}]"
        end # it

        it 'should set the resource class' do
          subclass = described_class[resource_class]

          expect(subclass.resource_class).to be resource_class
        end # it
      end # describe

      describe '::resource_class' do
        it 'should define the reader' do
          expect(described_class).
            to have_reader(:resource_class).
            with_value(resource_class)
        end # it
      end # describe

      describe '::resource_class=' do
        let(:new_resource_class) { Class.new }

        it 'should define the writer' do
          expect(described_class).not_to respond_to(:resource_class=)

          expect(described_class).
            to respond_to(:resource_class=, true).
            with(1).argument
        end # it

        it 'should set the resource class' do
          expect { described_class.send :resource_class=, new_resource_class }.
            to change(described_class, :resource_class).
            to be new_resource_class
        end # it
      end # describe

      describe '#repository' do
        include_examples 'should have reader',
          :repository,
          ->() { be == repository }
      end # describe

      describe '#repository=' do
        let(:new_repository) { double('repository') }

        it 'should define the private writer' do
          expect(instance).not_to respond_to(:repository=)

          expect(instance).to respond_to(:repository=, true).with(1).argument
        end # it

        it 'should set the repository' do
          expect { instance.send :repository=, new_repository }.
            to change(instance, :repository).
            to be new_repository
        end # it
      end # describe

      describe '#resource_class' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:resource_class).
            with_value(resource_class)
        end # it
      end # describe

      describe '#resource_collection' do
        let(:collection_name) { 'archived_periodicals' }

        it 'should define the method' do
          expect(instance).to respond_to(:resource_collection).with(0).arguments
        end # it

        it 'should return a collection' do
          collection = instance.resource_collection

          expect(collection).to be_a Bronze::Collections::Reference::Collection
          expect(collection.name).to be == collection_name
          expect(collection.repository).to be repository

          transform = collection.transform

          expect(transform).
            to be_a Bronze::Entities::Transforms::EntityTransform
          expect(transform.entity_class).to be resource_class
        end # it

        context 'when a custom transform is defined' do
          let(:transform) { Bronze::Transforms::IdentityTransform.new }

          before(:example) do
            allow(instance).
              to receive(:resource_transform_for).
              and_return(transform)
          end # before example

          it 'should return a collection' do
            collection = instance.resource_collection

            expect(collection).
              to be_a Bronze::Collections::Reference::Collection
            expect(collection.name).to be == collection_name
            expect(collection.repository).to be repository

            transform = collection.transform

            expect(transform).to be transform
          end # it
        end # context
      end # describe

      describe '#resource_name' do
        let(:expected) { 'archived_periodicals' }

        include_examples 'should have reader',
          :resource_name,
          ->() { be == expected }
      end # describe
    end # shared_examples

    shared_examples 'should implement the SingleResourceOperation methods' do
      include_examples 'should implement the ResourceOperation methods'

      describe '#build_resource' do
        let(:attributes) { {} }

        it { expect(instance).to respond_to(:build_resource).with(1).argument }

        it 'should build an instance of the resource class' do
          resource = instance.build_resource attributes
          expected = attributes.merge(:id => resource.id)

          expect(resource).to be_a resource_class
          expect(resource.attributes).to be == expected
        end # it

        it 'should set the resource' do
          resource = nil

          expect { resource = instance.build_resource attributes }.
            to change(instance, :resource)

          expect(instance.resource).to be == resource
        end # it
      end # describe

      describe '#find_resource' do
        let(:id)         { '0' }
        let(:attributes) { { :id => id } }
        let(:resource)   { resource_class.new(attributes) }

        it { expect(instance).to respond_to(:find_resource).with(1).argument }

        context 'when the repository does not have the requested resource' do
          it 'should return nil' do
            expect(instance.find_resource id).to be nil
          end # it
        end # context

        context 'when the repository has the requested resource' do
          before(:example) { instance.resource_collection.insert(resource) }

          it 'should return the resource' do
            expect(instance.find_resource id).to be == resource
          end # it
        end # context
      end # describe

      describe '#resource' do
        include_examples 'should have reader', :resource, nil
      end # describe
    end # shared_examples
  end # module
end # module
