# spec/patina/operations/entities/find_one_operation_spec.rb

require 'patina/collections/simple'
require 'patina/operations/entities/entity_operation_examples'
require 'patina/operations/entities/find_one_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::FindOneOperation do
  include Spec::Operations::EntityOperationExamples

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }

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
    describe 'with nil' do
      let(:expected_error) do
        error_definitions = Bronze::Collections::Collection::Errors

        Bronze::Errors::Error.new [:archived_periodical],
          error_definitions::RECORD_NOT_FOUND,
          :id => nil
      end # let

      it { expect(instance.call nil).to be false }

      it 'should not set the resource' do
        instance.call nil

        expect(instance.resource).to be nil
      end # it

      it 'should set the failure message' do
        instance.call nil

        expect(instance.failure_message).
          to be == described_class::RECORD_NOT_FOUND
      end # it

      it 'should append the error' do
        instance.call nil

        expect(instance.errors).to include expected_error
      end # it
    end # describe

    describe 'with a primary key that does not match a record' do
      let(:expected_error) do
        error_definitions = Bronze::Collections::Collection::Errors

        Bronze::Errors::Error.new [:archived_periodical],
          error_definitions::RECORD_NOT_FOUND,
          :id => primary_key
      end # let
      let(:primary_key) { Bronze::Entities::Ulid.generate }

      it { expect(instance.call primary_key).to be false }

      it 'should not set the resource' do
        instance.call primary_key

        expect(instance.resource).to be nil
      end # it

      it 'should set the failure message' do
        instance.call primary_key

        expect(instance.failure_message).
          to be == described_class::RECORD_NOT_FOUND
      end # it

      it 'should append the error' do
        instance.call primary_key

        expect(instance.errors).to include expected_error
      end # it
    end # describe

    wrap_context 'when the collection contains many resources' do
      describe 'with nil' do
        let(:expected_error) do
          error_definitions = Bronze::Collections::Collection::Errors

          Bronze::Errors::Error.new [:archived_periodical],
            error_definitions::RECORD_NOT_FOUND,
            :id => nil
        end # let

        it { expect(instance.call nil).to be false }

        it 'should not set the resource' do
          instance.call nil

          expect(instance.resource).to be nil
        end # it

        it 'should set the failure message' do
          instance.call nil

          expect(instance.failure_message).
            to be == described_class::RECORD_NOT_FOUND
        end # it

        it 'should append the error' do
          instance.call nil

          expect(instance.errors).to include expected_error
        end # it
      end # describe

      describe 'with a primary key that does not match a record' do
        let(:expected_error) do
          error_definitions = Bronze::Collections::Collection::Errors

          Bronze::Errors::Error.new [:archived_periodical],
            error_definitions::RECORD_NOT_FOUND,
            :id => primary_key
        end # let
        let(:primary_key) { Bronze::Entities::Ulid.generate }

        it { expect(instance.call primary_key).to be false }

        it 'should not set the resource' do
          instance.call primary_key

          expect(instance.resource).to be nil
        end # it

        it 'should set the failure message' do
          instance.call primary_key

          expect(instance.failure_message).
            to be == described_class::RECORD_NOT_FOUND
        end # it

        it 'should append the error' do
          instance.call primary_key

          expect(instance.errors).to include expected_error
        end # it
      end # describe

      describe 'with a primary key that matches a record' do
        let(:resource)    { resources.first }
        let(:primary_key) { resource.id }

        it { expect(instance.call primary_key).to be true }

        it 'should set the resource' do
          instance.call primary_key

          expect(instance.resource).to be == resource
          expect(instance.resource.attributes_changed?).to be false
          expect(instance.resource.persisted?).to be true
        end # it

        it 'should clear the failure message' do
          instance.call primary_key

          expect(instance.failure_message).to be nil
        end # it

        it 'should append the error' do
          instance.call primary_key

          expect(instance.errors.empty?).to be true
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
