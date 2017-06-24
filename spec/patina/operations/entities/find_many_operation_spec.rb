# spec/patina/operations/entities/find_many_operation_spec.rb

require 'bronze/collections/collection'

require 'patina/collections/simple'
require 'patina/operations/entities/entity_operation_examples'
require 'patina/operations/entities/find_many_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::FindManyOperation do
  include Spec::Operations::EntityOperationExamples

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }

  options = { :base_class => Spec::ExampleEntity }
  example_class 'Spec::ArchivedPeriodical', options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # example_class

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
    shared_examples 'should find the matching records and return true' do
      it { expect(instance.call primary_keys).to be true }

      it 'should set the resources' do
        instance.call primary_keys

        expect(instance.resources).to be == expected

        instance.resources.each do |resource|
          expect(resource.attributes_changed?).to be false
          expect(resource.persisted?).to be true
        end # each
      end # it

      it 'should clear the failure message' do
        instance.call primary_keys

        expect(instance.failure_message).to be nil
      end # it

      it 'should clear the errors' do
        instance.call primary_keys

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    shared_examples 'should find the matching records and return false' do
      let(:missing_primary_keys) do
        primary_keys - expected.map(&:id)
      end # let

      it { expect(instance.call primary_keys).to be false }

      it 'should set the resources' do
        instance.call primary_keys

        expect(instance.resources).to be == expected

        instance.resources.each do |resource|
          expect(resource.attributes_changed?).to be false
          expect(resource.persisted?).to be true
        end # each
      end # it

      it 'should set the failure message' do
        instance.call primary_keys

        expect(instance.failure_message).
          to be described_class::RECORD_NOT_FOUND
      end # it

      it 'should append the errors' do
        error_definitions = Bronze::Collections::Collection::Errors

        instance.call primary_keys

        missing_primary_keys.each do |primary_key|
          expected_error = {
            :type   => error_definitions::RECORD_NOT_FOUND,
            :params => { :id => primary_key },
            :path   => [:archived_periodicals, primary_key.intern]
          } # end expected_error

          expect(instance.errors).to include(expected_error)
        end # each
      end # it
    end # shared_examples

    let(:resources)    { [] }
    let(:primary_keys) { {} }
    let(:expected) do
      resources.select { |resource| primary_keys.include?(resource.id) }
    end # let

    describe 'with an empty array' do
      include_examples 'should find the matching records and return true'
    end # describe

    describe 'with a non-matching list of primary keys' do
      let(:primary_keys) { Array.new(3) { Bronze::Entities::Ulid.generate } }

      include_examples 'should find the matching records and return false'
    end # describe

    wrap_context 'when the collection contains many resources' do
      describe 'with an empty array' do
        include_examples 'should find the matching records and return true'
      end # describe

      describe 'with a non-matching list of primary keys' do
        let(:primary_keys) { Array.new(3) { Bronze::Entities::Ulid.generate } }

        include_examples 'should find the matching records and return false'
      end # describe

      describe 'with a partially matching list of primary keys' do
        let(:primary_keys) do
          keys = []

          keys.concat Array.new(3) { Bronze::Entities::Ulid.generate }
          keys.concat expected.map(&:id)

          keys
        end # let
        let(:expected) { resources[0...3] }

        include_examples 'should find the matching records and return false'
      end # describe

      describe 'with a matching list of primary keys' do
        let(:primary_keys) { expected.map(&:id) }
        let(:expected)     { resources[0...3] }

        include_examples 'should find the matching records and return true'
      end # describe

      describe 'with a matching list of primary keys with duplicate keys' do
        let(:primary_keys) { [*expected.map(&:id), expected.first.id] }
        let(:expected)     { resources[0...3] }

        include_examples 'should find the matching records and return true'
      end # describe
    end # wrap_context
  end # describe

  describe '#resources' do
    include_examples 'should have reader', :resources, nil
  end # describe
end # describe
