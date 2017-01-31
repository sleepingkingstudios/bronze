# spec/patina/operations/resources/update_one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/resource_operation_examples'
require 'patina/operations/resources/update_one_resource_operation'

RSpec.describe Patina::Operations::Resources::UpdateOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::UpdateOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :UpdateOneResourceOperation, options do |klass|
    klass.send :include,
      Patina::Operations::Resources::UpdateOneResourceOperation

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
      instance.call resource_id, attributes
    end # method call_operation

    include_examples 'should require a resource'

    wrap_context 'when the collection contains one resource' do
      shared_examples 'should perform the operation' do
        it { expect(instance.call resource_id, attributes).to be true }

        it 'should set the resource' do
          instance.call resource_id, attributes

          resource = instance.resource

          expect(resource).to be_a resource_class
          expect(resource.title).to be == resource_attributes[:title]
          expect(resource.volume).to be == attributes[:volume]

          expect(resource.attributes_changed?).to be false
          expect(resource.persisted?).to be true
        end # it

        it 'should update the persisted resource' do
          transform  =
            Bronze::Entities::Transforms::EntityTransform.new(resource_class)
          collection = repository.collection(resource_class, transform)

          expect { instance.call resource_id, attributes }.
            to change { collection.find resource_id }

          expect(collection.find resource_id).to be == instance.resource
        end # it

        it 'should clear the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          instance.call resource_id, attributes

          expect(instance.errors).to satisfy(&:empty?)
        end # it
      end # shared_examples

      let(:resource_id) { resource.id }
      let(:attributes)  { { :volume => 7 } }

      include_examples 'should require a resource'

      include_examples 'should perform the operation'

      describe 'with a failing update' do
        let(:errors) do
          Bronze::Errors::Errors.new.tap do |errors|
            errors[:user].add :not_authorized
          end # tap
        end # let

        before(:example) do
          allow(instance.resource_collection).to receive(:update) do |*|
            [false, errors]
          end # allow
        end # before example

        it { expect(instance.call resource_id, attributes).to be false }

        it 'should set the resource' do
          instance.call resource_id, attributes

          resource = instance.resource

          expect(resource).to be_a resource_class
          expect(resource.title).to be == resource_attributes[:title]
          expect(resource.volume).to be == attributes[:volume]

          expect(resource.attributes_changed?).to be true
          expect(resource.persisted?).to be true
        end # it

        it 'should not update the persisted resource' do
          collection = repository.collection(resource_class)

          expect { instance.call resource_id, attributes }.
            not_to change { collection.find resource_id }
        end # it

        it 'should set the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          instance.call resource_id, attributes

          expect(instance.errors).to be == errors
        end # it
      end # describe

      describe 'with a failing validation' do
        before(:example) do
          described_class.contract do
            add_constraint Spec::Constraints::FailureConstraint.new
          end # contract
        end # before example

        it { expect(instance.call resource_id, attributes).to be false }

        it 'should set the resource' do
          instance.call resource_id, attributes

          resource = instance.resource

          expect(resource).to be_a resource_class
          expect(resource.title).to be == resource_attributes[:title]
          expect(resource.volume).to be == attributes[:volume]

          expect(resource.attributes_changed?).to be true
          expect(resource.persisted?).to be true
        end # it

        it 'should not update the persisted resource' do
          collection = repository.collection(resource_class)

          expect { instance.call resource_id, attributes }.
            not_to change { collection.find resource_id }
        end # it

        it 'should set the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          instance.call resource_id, attributes

          expect(instance.errors).to include { |error|
            error.type == Spec::Constraints::FailureConstraint::INVALID_ERROR
          } # end include
        end # it
      end # describe

      describe 'with a passing validation' do
        before(:example) do
          described_class.contract do
            add_constraint Spec::Constraints::SuccessConstraint.new
          end # contract
        end # before example

        include_examples 'should perform the operation'
      end # describe
    end # wrap_context
  end # describe
end # describe
