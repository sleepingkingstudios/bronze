# spec/patina/operations/resources/destroy_one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'patina/operations/resources/resource_operation_examples'
require 'patina/operations/resources/destroy_one_resource_operation'

RSpec.describe Patina::Operations::Resources::DestroyOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::DestroyOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = {
    :base_class => Patina::Operations::Resources::DestroyOneResourceOperation
  } # end options
  mock_class Spec::Operations, :DestroyOneResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'

  describe '#call' do
    let(:attributes)  { {} }
    let(:resource_id) { '0' }

    def call_operation
      instance.call resource_id
    end # method call_operation

    include_context 'should require a resource'

    wrap_context 'when the collection contains one resource' do
      include_context 'should require a resource'

      describe 'with a valid resource id' do
        let(:resource_id) { resource.id }

        it { expect(instance.call resource_id).to be true }

        it 'should set the resource' do
          instance.call resource_id

          resource = instance.resource

          expect(resource).to be == resource
        end # it

        it 'should delete the persisted resource' do
          collection = repository.collection(resource_class)

          expect { instance.call resource_id }.
            to change(collection, :count).by(-1)

          expect(collection.find resource_id).to be nil
        end # it

        it 'should clear the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          instance.call resource_id

          expect(instance.errors).to satisfy(&:empty?)
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
