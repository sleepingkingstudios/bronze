# spec/patina/operations/entities/insert_one_operation_spec.rb

require 'patina/collections/simple'
require 'patina/operations/entities/entity_operation_examples'
require 'patina/operations/entities/insert_one_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::InsertOneOperation do
  include Spec::Operations::EntityOperationExamples

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }
  let(:collection) do
    repository.collection(resource_class, instance.send(:transform))
  end # let

  options = { :base_class => Spec::ExampleEntity }
  example_class 'Spec::ArchivedPeriodical', options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # example_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '::RECORD_ALREADY_EXISTS' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_ALREADY_EXISTS).
        with_value('errors.operations.entities.record_already_exists')
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should return false and set the errors' do
      let(:expected_error) do
        error_definitions = Bronze::Collections::Collection::Errors

        {
          :type   => error_definitions::RECORD_ALREADY_EXISTS,
          :params => { :id => resource.id },
          :path   => [:archived_periodical]
        } # end expected_error
      end # let

      it { expect(instance.call resource).to be false }

      it 'should not insert the record into the collection' do
        expect { instance.call resource }.not_to change(collection, :count)
      end # it

      it 'should set the resource' do
        instance.call resource

        expect(instance.resource).to be resource
      end # it

      it 'should set the errors' do
        instance.call resource

        expect(instance.errors).to include expected_error
      end # it
    end # shared_examples

    shared_examples 'should insert the resource and return true' do
      it { expect(instance.call resource).to be true }

      it 'should insert the record into the collection' do
        expect { instance.call resource }.to change(collection, :count).by(1)

        expect(collection.to_a).to include resource
      end # it

      it 'should set the resource' do
        instance.call resource

        expect(instance.resource).to be resource
      end # it

      it 'should clear the errors' do
        instance.call resource

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    describe 'with a resource that is not in the repository' do
      let(:resource) { resource_class.new }

      include_examples 'should insert the resource and return true'
    end # describe

    wrap_context 'when the collection contains many resources' do
      describe 'with a resource that is not in the repository' do
        let(:resource) { resource_class.new }

        include_examples 'should insert the resource and return true'
      end # describe

      describe 'with a resource that is in the repository' do
        let(:resource) { resources.last }

        include_examples 'should return false and set the errors'
      end # describe
    end # wrap_context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
