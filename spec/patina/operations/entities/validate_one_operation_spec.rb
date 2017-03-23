# spec/patina/operations/entities/validate_one_operation_spec.rb

require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'

require 'patina/operations/entities/validate_one_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::ValidateOneOperation do
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new }

  options = { :base_class => Spec::ExampleEntity }
  mock_class Spec, :ArchivedPeriodical, options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::INVALID_RESOURCE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:INVALID_RESOURCE).
        with_value('errors.operations.entities.invalid_resource')
    end # it
  end # describe

  describe '#call' do
    let(:resource) { resource_class.new }
    let(:contract) { nil }

    shared_examples 'should validate the resource and set the errors' do
      let(:expected_error) do
        {
          :type => Spec::Constraints::FailureConstraint::INVALID_ERROR,
          :path => [:archived_periodical]
        } # end expected_error
      end # let

      it { expect(instance.call resource, contract).to be false }

      it 'should set the resource' do
        instance.call resource, contract

        expect(instance.resource).to be resource
      end # it

      it 'should set the failure message' do
        instance.call resource, contract

        expect(instance.failure_message).to be described_class::INVALID_RESOURCE
      end # it

      it 'should set the errors' do
        instance.call resource, contract

        expect(instance.errors).to include expected_error
      end # it
    end # shared_examples

    shared_examples 'should validate the resource and return true' do
      it { expect(instance.call resource, contract).to be true }

      it 'should set the resource' do
        instance.call resource, contract

        expect(instance.resource).to be resource
      end # it

      it 'should clear the failure message' do
        instance.call resource, contract

        expect(instance.failure_message).to be nil
      end # it

      it 'should clear the errors' do
        instance.call resource, contract

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    describe 'with a resource' do
      include_examples 'should validate the resource and return true'
    end # describe

    describe 'with a resource and an invalid contract' do
      let(:contract) { Spec::Constraints::FailureConstraint.new }

      include_examples 'should validate the resource and set the errors'
    end # describe

    describe 'with a resource and a valid contract' do
      let(:contract) { Spec::Constraints::SuccessConstraint.new }

      include_examples 'should validate the resource and return true'
    end # describe

    context 'when the resource class defines ::Contract as a contract class' do
      context 'when the contract is invalid' do
        before(:example) do
          contract_class = Class.new(Bronze::Contracts::Contract)

          contract_class.add_constraint Spec::Constraints::FailureConstraint.new

          resource_class.const_set :Contract, contract_class
        end # before example

        include_examples 'should validate the resource and set the errors'

        describe 'with a resource and an invalid contract' do
          let(:contract) { Spec::Constraints::FailureConstraint.new }

          include_examples 'should validate the resource and set the errors'
        end # describe

        describe 'with a resource and a valid contract' do
          let(:contract) { Spec::Constraints::SuccessConstraint.new }

          include_examples 'should validate the resource and return true'
        end # describe
      end # context

      context 'when the contract is valid' do
        before(:example) do
          contract_class = Class.new(Bronze::Contracts::Contract)

          contract_class.add_constraint Spec::Constraints::SuccessConstraint.new

          resource_class.const_set :Contract, contract_class
        end # before example

        include_examples 'should validate the resource and return true'

        describe 'with a resource and an invalid contract' do
          let(:contract) { Spec::Constraints::FailureConstraint.new }

          include_examples 'should validate the resource and set the errors'
        end # describe

        describe 'with a resource and a valid contract' do
          let(:contract) { Spec::Constraints::SuccessConstraint.new }

          include_examples 'should validate the resource and return true'
        end # describe
      end # context
    end # context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
