# spec/patina/operations/resources/find_many_resources_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/find_many_resources_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::FindManyResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::FindManyResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :FindManyResourcesOperation, options do |klass|
    klass.send :include,
      Patina::Operations::Resources::FindManyResourcesOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ManyResourcesOperation methods'

  describe '#call' do
    shared_examples 'should find the resources and return true' do
      it { expect(call_operation).to be true }

      it 'should set the resources' do
        call_operation

        expect(instance.resources).to be == expected

        instance.resources.each do |resource|
          expect(resource.attributes_changed?).to be false
          expect(resource.persisted?).to be true
        end # each

        expect(instance.resources_count).to be == expected.count
        expect(instance.missing_resource_ids).to be == []
      end # it

      it 'should clear the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        call_operation

        expect(instance.errors).to satisfy(&:empty?)
      end # it

      it 'should clear the failure message' do
        previous_message = 'We require more minerals.'

        instance.instance_variable_set :@failure_message, previous_message

        call_operation

        expect(instance.failure_message).to be nil
      end # it
    end # shared_examples

    shared_examples 'should return false and set the errors' do
      let(:missing_ids) { resource_ids - resources.map(&:id) }

      it { expect(call_operation).to be false }

      it 'should set the resource' do
        call_operation

        expect(instance.resources).to be == expected
      end # it

      it 'should set the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        call_operation

        error_definitions = Bronze::Collections::Collection::Errors

        missing_ids.each do |missing_id|
          expected =
            Bronze::Errors::Error.new [:resources, missing_id.to_s.intern],
              error_definitions::RECORD_NOT_FOUND,
              :id => missing_id

          expect(instance.errors).to include expected
        end # each
      end # it

      it 'should set the failure message' do
        call_operation

        expect(instance.failure_message).
          to be == described_class::RESOURCES_NOT_FOUND
      end # it
    end # shared_examples

    let(:resource_ids) { [] }
    let(:expected)     { [] }

    def call_operation
      instance.call resource_ids
    end # method call_operation

    include_examples 'should find the resources and return true'

    wrap_context 'when the collection contains many resources' do
      include_examples 'should find the resources and return true'

      describe 'with a non-matching list of ids' do
        let(:resource_ids) { Array.new(3) { Bronze::Entities::Ulid.generate } }

        include_examples 'should return false and set the errors'
      end # describe

      describe 'with a partially matching list of ids' do
        let(:resource_ids) do
          resources[0...3].map(&:id).concat(
            Array.new(3) { Bronze::Entities::Ulid.generate }
          ) # end concat
        end # let
        let(:expected) { resources[0...3] }

        include_examples 'should return false and set the errors'
      end # describe

      describe 'with a matching list of ids' do
        let(:resource_ids) do
          resources[0...3].map(&:id)
        end # let
        let(:expected) { resources[0...3] }

        include_examples 'should find the resources and return true'
      end # describe
    end # method wrap_context
  end # describe
end # describe
