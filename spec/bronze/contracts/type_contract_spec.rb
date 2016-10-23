# spec/bronze/contracts/type_contract_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'
require 'bronze/contracts/contract_builder'
require 'bronze/contracts/type_contract'

RSpec.describe Bronze::Contracts::TypeContract do
  include Spec::Constraints::ConstraintsExamples

  let(:described_class) do
    klass = Class.new
    klass.send :include, super()
    klass
  end # let

  describe '::contract' do
    it 'should define the method' do
      expect(described_class).
        to respond_to(:contract).
        with(0).arguments.
        and_a_block
    end # it

    it 'should return an empty contract' do
      contract = described_class.contract

      expect(contract).to be_a Bronze::Contracts::Contract
      expect(contract.constraints).to satisfy(&:empty?)
    end # it

    describe 'with a block' do
      it 'should execute the block in the context of a contract builder' do
        contract  = described_class.contract
        called_by = nil

        described_class.contract do
          called_by = self
        end # contract

        expect(called_by).to be_a Bronze::Contracts::ContractBuilder
        expect(called_by.contract).to be contract
      end # it

      it 'should add the specified constraints' do
        contract = described_class.contract do
          constrain :title, :present => true

          constrain :isbn, :type => String, :nil => false
        end # contract

        constraints = contract.constraints

        expect(constraints).to include { |data|
          data.constraint.is_a?(Bronze::Constraints::PresenceConstraint) &&
            data.nesting == [:title] &&
            !data.negated?
        } # end include

        expect(constraints).to include { |data|
          data.constraint.is_a?(Bronze::Constraints::TypeConstraint) &&
            data.constraint.type == String &&
            data.nesting == [:isbn] &&
            !data.negated?
        } # end include

        expect(constraints).to include { |data|
          data.constraint.is_a?(Bronze::Constraints::NilConstraint) &&
            data.nesting == [:isbn] &&
            data.negated?
        } # end include
      end # it
    end # describe
  end # describe

  describe '::match' do
    let(:object)   { double('object') }
    let(:instance) { described_class }

    it { expect(described_class).to respond_to(:match).with(1).argument }

    context 'with a contract that matches the object' do
      before(:example) do
        described_class.contract do
          add_constraint Spec::SuccessConstraint.new
        end # contract
      end # before example

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a contract that does not match the object' do
      let(:error_type) { Spec::FailureConstraint::INVALID_ERROR }

      before(:example) do
        described_class.contract do
          add_constraint Spec::FailureConstraint.new
        end # contract
      end # before example

      include_examples 'should return false and the errors object'
    end # context
  end # describe
end # describe
