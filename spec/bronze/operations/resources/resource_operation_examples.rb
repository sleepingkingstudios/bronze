# spec/bronze/operations/resources/resource_operation_examples.rb

require 'bronze/collections/collection'
require 'bronze/entities/entity'
require 'bronze/entities/transforms/entity_transform'
require 'bronze/errors/error'
require 'bronze/transforms/identity_transform'

module Spec::Operations
  module ResourceOperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when a resource class is defined' do
      let(:resource_class) { Spec::ArchivedPeriodical }

      options = { :base_class => Bronze::Entities::Entity }
      mock_class Spec, :ArchivedPeriodical, options do |klass|
        klass.attribute :title,  String
        klass.attribute :volume, Integer
      end # mock_class
    end # shared_context

    shared_context 'when the collection contains one resource' do
      let(:resource_attributes) do
        { :title => 'Your Weekly Horoscope', :volume => 0 }
      end # let
      let(:resource) { resource_class.new resource_attributes }

      before(:example) { instance.resource_collection.insert resource }
    end # shared_context

    shared_context 'when the collection contains many resources' do
      let(:resources_attributes) do
        ary = []

        title = 'Astrology Today'
        1.upto(3) { |i| ary << { :title => title, :volume => i } }

        title = 'Journal of Applied Phrenology'
        4.upto(6) { |i| ary << { :title => title, :volume => i } }

        ary
      end # let
      let(:resources) do
        resources_attributes.map { |hsh| resource_class.new hsh }
      end # let

      before(:example) do
        resources.each do |resource|
          instance.resource_collection.insert resource
        end # each
      end # before
    end # shared_context

    shared_examples 'should require a resource' do
      let(:errors) do
        error_definitions = Bronze::Collections::Collection::Errors

        Bronze::Errors::Errors.new.tap do |errors|
          errors[:resource].add(
            error_definitions::RECORD_NOT_FOUND,
            :id,
            resource_id
          ) # end add error
        end # tap
      end # let

      it { expect(call_operation).to be false }

      it 'should set the resource' do
        call_operation

        expect(instance.resource).to be nil
      end # it

      it 'should set the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        call_operation

        expect(instance.errors).to be == errors
      end # it
    end # shared_context

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

    shared_examples 'should implement the ManyResourcesOperation methods' do
      include_examples 'should implement the ResourceOperation methods'

      describe '#find_resources' do
        shared_examples 'should set and return the resources' do
          it 'should return the resources' do
            resources = instance.send(:find_resources, *arguments)

            expect(resources).to be == expected
          end # it

          it 'should set the resources' do
            resources = nil

            expect { resources = instance.send(:find_resources, *arguments) }.
              to change(instance, :resources)

            expect(instance.resources).to be == expected
          end # it
        end # shared_examples

        let(:arguments) { [] }
        let(:expected)  { [] }

        it 'should define the method' do
          expect(instance).
            to respond_to(:find_resources, true).
            with(0).arguments.
            and_keywords(:matching)
        end # it

        include_examples 'should set and return the resources'

        wrap_context 'when the collection contains many resources' do
          let(:expected) { resources }

          include_examples 'should set and return the resources'
        end # wrap_context

        describe 'with :matching => selector' do
          let(:selector)  { { :title => 'Journal of Applied Phrenology' } }
          let(:arguments) { super() << { :matching => selector } }

          include_examples 'should set and return the resources'

          wrap_context 'when the collection contains many resources' do
            let(:expected) do
              resources.select do |resource|
                resource.title == selector[:title]
              end # select
            end # let

            include_examples 'should set and return the resources'
          end # wrap_context
        end # describe
      end # describe

      describe '#resources' do
        include_examples 'should have reader', :resources, nil
      end # describe
    end # shared_examples

    shared_examples 'should implement the OneResourceOperation methods' do
      include_examples 'should implement the ResourceOperation methods'

      describe '#build_resource' do
        let(:attributes) { {} }

        it 'should define the method' do
          expect(instance).to respond_to(:build_resource, true).with(1).argument
        end # it

        it 'should build an instance of the resource class' do
          resource = instance.send :build_resource, attributes
          expected = {}

          resource_class.attributes.each do |attr_name, _|
            expected[attr_name] = attributes[attr_name]
          end # each

          expected = expected.merge(:id => resource.id)

          expect(resource).to be_a resource_class
          expect(resource.attributes).to be == expected
        end # it

        it 'should set the resource' do
          resource = nil

          expect { resource = instance.send :build_resource, attributes }.
            to change(instance, :resource)

          expect(instance.resource).to be == resource
        end # it
      end # describe

      describe '#find_resource' do
        let(:resource_id) { '0' }
        let(:attributes)  { { :id => resource_id } }
        let(:resource)    { resource_class.new(attributes) }

        it 'should define the method' do
          expect(instance).to respond_to(:find_resource, true).with(1).argument
        end # it

        context 'when the repository does not have the requested resource' do
          it 'should return nil' do
            expect(instance.send :find_resource, resource_id).to be nil
          end # it

          it 'should clear the resource' do
            instance.send :find_resource, resource_id

            expect(instance.resource).to be nil
          end # it
        end # context

        context 'when the repository has the requested resource' do
          before(:example) { instance.resource_collection.insert(resource) }

          it 'should return the resource' do
            expect(instance.send :find_resource, resource_id).to be == resource
          end # it

          it 'should set the resource' do
            expect { instance.send :find_resource, resource_id }.
              to change(instance, :resource)

            expect(instance.resource).to be == resource
          end # it
        end # context
      end # describe

      describe '#require_resource' do
        let(:expected) do
          error_definitions = Bronze::Collections::Collection::Errors

          Bronze::Errors::Error.new [:resource],
            error_definitions::RECORD_NOT_FOUND,
            [:id, resource_id]
        end # let
        let(:resource_id) { '0' }
        let(:attributes)  { { :id => resource_id } }
        let(:resource)    { resource_class.new(attributes) }

        before(:example) do
          instance.instance_variable_set :@errors, Bronze::Errors::Errors.new
        end # before example

        it 'should define the method' do
          expect(instance).
            to respond_to(:require_resource, true).
            with(1).argument
        end # it

        context 'when the repository does not have the requested resource' do
          it 'should return false' do
            expect(instance.send :require_resource, resource_id).to be false
          end # it

          it 'should clear the resource' do
            instance.send :require_resource, resource_id

            expect(instance.resource).to be nil
          end # it

          it 'should append the error' do
            instance.send :require_resource, resource_id

            expect(instance.errors).to include(expected)
          end # it
        end # context

        context 'when the repository has the requested resource' do
          before(:example) { instance.resource_collection.insert(resource) }

          it 'should return the resource' do
            expect(instance.send :find_resource, resource_id).to be == resource
          end # it

          it 'should set the resource' do
            expect { instance.send :find_resource, resource_id }.
              to change(instance, :resource)

            expect(instance.resource).to be == resource
          end # it

          it 'should not append an error' do
            instance.send :require_resource, resource_id

            expect { instance.errors }.not_to change(instance, :errors)
          end # it
        end # context
      end # describe

      describe '#resource' do
        include_examples 'should have reader', :resource, nil
      end # describe
    end # shared_examples
  end # module
end # module
