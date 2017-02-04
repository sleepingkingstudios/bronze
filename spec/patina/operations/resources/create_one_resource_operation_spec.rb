# spec/patina/operations/resources/create_one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/errors/errors'

require 'patina/operations/resources/create_one_resource_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::CreateOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::CreateOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :CreateOneResourceOperation, options do |klass|
    klass.send :include,
      Patina::Operations::Resources::CreateOneResourceOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'

  describe '#call' do
    shared_examples 'should perform the operation' do
      it { expect(instance.call attributes).to be true }

      it 'should set the resource' do
        instance.call attributes

        resource = instance.resource

        expect(resource).to be_a resource_class
        expect(resource.title).to be == attributes[:title]
        expect(resource.volume).to be == attributes[:volume]

        expect(resource.attributes_changed?).to be false
        expect(resource.persisted?).to be true
      end # it

      it 'should persist the resource' do
        collection = repository.collection(resource_class)

        expect { instance.call attributes }.to change(collection, :count).by(1)
      end # it

      it 'should clear the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call attributes

        expect(instance.errors).to satisfy(&:empty?)
      end # it

      it 'should clear the failure message' do
        previous_message = 'We require more minerals.'

        instance.instance_variable_set :@failure_message, previous_message

        instance.call attributes

        expect(instance.failure_message).to be nil
      end # it
    end # shared_examples

    let(:attributes) { { :title => 'Journal of Phrenology', :volume => 13 } }

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should perform the operation'

    describe 'with a failing insertion' do
      let(:errors) do
        Bronze::Errors::Errors.new.tap do |errors|
          errors[:user].add :not_authorized
        end # tap
      end # let

      before(:example) do
        allow(instance.resource_collection).to receive(:insert) do |_|
          [false, errors]
        end # allow
      end # before example

      it { expect(instance.call attributes).to be false }

      it 'should set the resource' do
        instance.call attributes

        resource = instance.resource

        expect(resource).to be_a resource_class
        expect(resource.title).to be == attributes[:title]
        expect(resource.volume).to be == attributes[:volume]

        expect(resource.attributes_changed?).to be false
        expect(resource.persisted?).to be false
      end # it

      it 'should not persist the resource' do
        collection = repository.collection(resource_class)

        expect { instance.call attributes }.not_to change(collection, :count)
      end # it

      it 'should set the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call attributes

        expect(instance.errors).to be == errors
      end # it
    end # describe

    describe 'with a failing validation' do
      before(:example) do
        described_class.contract do
          add_constraint Spec::Constraints::FailureConstraint.new
        end # contract
      end # before example

      it { expect(instance.call attributes).to be false }

      it 'should set the resource' do
        instance.call attributes

        resource = instance.resource

        expect(resource).to be_a resource_class
        expect(resource.title).to be == attributes[:title]
        expect(resource.volume).to be == attributes[:volume]

        expect(resource.attributes_changed?).to be false
        expect(resource.persisted?).to be false
      end # it

      it 'should not persist the resource' do
        collection = repository.collection(resource_class)

        expect { instance.call attributes }.not_to change(collection, :count)
      end # it

      it 'should set the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call attributes

        expect(instance.errors).to include { |error|
          error.type == Spec::Constraints::FailureConstraint::INVALID_ERROR
        } # end include
      end # it

      it 'should set the failure message' do
        instance.call attributes

        expect(instance.failure_message).
          to be == described_class::INVALID_RESOURCE
      end # describe
    end # describe

    describe 'with a passing validation' do
      before(:example) do
        described_class.contract do
          add_constraint Spec::Constraints::SuccessConstraint.new
        end # contract
      end # before example

      include_examples 'should perform the operation'
    end # describe
  end # describe
end # describe
