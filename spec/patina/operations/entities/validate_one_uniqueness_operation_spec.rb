# spec/patina/operations/entities/validate_one_uniqueness_operation.rb

require 'bronze/entities/constraints/uniqueness_constraint'

require 'patina/collections/simple'
require 'patina/operations/entities/entity_operation_examples'
require 'patina/operations/entities/validate_one_uniqueness_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::ValidateOneUniquenessOperation do
  include Spec::Operations::EntityOperationExamples

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }
  let(:collection)     { instance.send :collection }

  options = { :base_class => Spec::ExampleEntity }
  example_class 'Spec::ArchivedPeriodical', options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # example_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '::RECORD_NOT_UNIQUE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_NOT_UNIQUE).
        with_value('errors.operations.entities.record_not_unique')
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should return false and set the errors' do
      let(:expected_error) do
        error_definitions =
          Bronze::Entities::Constraints::UniquenessConstraint

        {
          :type   => error_definitions::NOT_UNIQUE_ERROR,
          :params => { :id => resource.id },
          :path   => [:archived_periodical]
        } # end expected_error
      end # let

      it { expect(instance.call resource).to be false }

      it 'should set the resource' do
        instance.call resource

        expect(instance.resource).to be resource
      end # it

      it 'should set the failure message' do
        instance.call resource

        expect(instance.failure_message).
          to be described_class::RECORD_NOT_UNIQUE
      end # it

      it 'should set the errors' do
        instance.call resource

        expect(instance.errors).to include expected_error
      end # it
    end # shared_examples

    shared_examples 'should set the resource and return true' do
      it { expect(instance.call resource).to be true }

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

    let(:attributes) { {} }
    let(:resource)   { resource_class.new attributes }

    include_examples 'should set the resource and return true'

    context 'when the entity does not implement uniqueness' do
      let(:resource_class) { Spec::SimplePeriodical }

      options = { :base_class => Bronze::Entities::BaseEntity }
      example_class 'Spec::SimplePeriodical', options do |klass|
        klass.send :include, Bronze::Entities::Attributes

        klass.attribute :title,  String
        klass.attribute :volume, Integer
      end # example_class

      include_examples 'should set the resource and return true'
    end # context

    context 'when the entity is unique in the collection' do
      before(:example) do
        allow(resource).
          to receive(:match_uniqueness).
          with(collection).
          and_return(true, {})
      end # before example

      include_examples 'should set the resource and return true'
    end # context

    context 'when the entity is not unique in the collection' do
      let(:errors) do
        error_definitions =
          Bronze::Entities::Constraints::UniquenessConstraint
        errors = Bronze::Errors.new

        errors.add(
          error_definitions::NOT_UNIQUE_ERROR,
          :id => resource.id
        ) # end errors

        errors
      end # let

      before(:example) do
        allow(resource).
          to receive(:match_uniqueness).
          with(collection).
          and_return([false, errors])
      end # before example

      include_examples 'should return false and set the errors'
    end # context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
