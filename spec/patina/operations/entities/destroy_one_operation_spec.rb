# spec/patina/operations/entities/destroy_one_operation_spec.rb

require 'patina/collections/simple'
require 'patina/operations/entities/destroy_one_operation'
require 'patina/operations/entities/entity_operation_examples'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::DestroyOneOperation do
  include Spec::Operations::EntityOperationExamples

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }
  let(:collection) do
    repository.collection(resource_class, instance.send(:transform))
  end # let

  options = { :base_class => Spec::ExampleEntity }
  mock_class Spec, :ArchivedPeriodical, options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '::RECORD_NOT_FOUND' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_NOT_FOUND).
        with_value('errors.operations.entities.record_not_found')
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should return false and set the errors' do
      let(:expected_error) do
        error_definitions = Bronze::Collections::Collection::Errors

        {
          :type   => error_definitions::RECORD_NOT_FOUND,
          :params => { :id => resource.id }
        } # end expected_error
      end # let

      it { expect(instance.call resource).to be false }

      it 'should not remove the record from the collection' do
        expect { instance.call resource }.not_to change(collection, :count)
      end # it

      it 'should set the resource' do
        instance.call resource

        expect(instance.resource).to be resource
      end # it

      it 'should set the failure message' do
        instance.call resource

        expect(instance.failure_message).to be described_class::RECORD_NOT_FOUND
      end # it

      it 'should set the errors' do
        instance.call resource

        expect(instance.errors).to include expected_error
      end # it
    end # shared_examples

    shared_examples 'should destroy the resource and return true' do
      it { expect(instance.call resource).to be true }

      it 'should remove the record from the collection' do
        expect { instance.call resource }.to change(collection, :count).by(-1)

        expect(collection.to_a).not_to include resource
      end # it

      it 'should set the resource' do
        instance.call resource

        expect(instance.resource).to be resource
      end # it

      it 'should clear the failure message' do
        instance.call resource

        expect(instance.failure_message).to be nil
      end # it

      it 'should clear the errors' do
        instance.call resource

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    describe 'with a resource that is not in the repository' do
      let(:resource) { resource_class.new }

      include_examples 'should return false and set the errors'
    end # describe

    wrap_context 'when the collection contains many resources' do
      describe 'with a resource that is not in the repository' do
        let(:resource) { resource_class.new }

        include_examples 'should return false and set the errors'
      end # describe

      describe 'with a resource that is in the repository' do
        let(:resource) { resources.first }

        include_examples 'should destroy the resource and return true'
      end # describe
    end # wrap_context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
