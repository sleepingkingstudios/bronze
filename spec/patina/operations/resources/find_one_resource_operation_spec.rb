# spec/patina/operations/resources/find_one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/find_one_resource_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::FindOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::FindOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :FindOneResourceOperation, options do |klass|
    klass.send :include, Patina::Operations::Resources::FindOneResourceOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'

  describe '#call' do
    let(:resource_id) { '0' }

    def call_operation
      instance.call resource_id
    end # method call_operation

    include_context 'should require a resource'

    wrap_context 'when the collection contains one resource' do
      include_context 'should require a resource'

      describe 'with a valid resource id' do
        let(:resource_id) { resource.id }
        let(:expected)    { resource }

        it { expect(call_operation).to be true }

        it 'should set the resource' do
          call_operation

          expect(instance.resource).to be == expected
          expect(instance.resource.attributes_changed?).to be false
          expect(instance.resource.persisted?).to be true
        end # it

        it 'should clear the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          call_operation

          expect(instance.errors).to satisfy(&:empty?)
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
