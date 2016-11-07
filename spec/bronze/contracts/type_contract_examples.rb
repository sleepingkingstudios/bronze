# spec/bronze/contracts/type_contract_examples.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'

module Spec::Contracts
  module TypeContractExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Constraints::ConstraintsExamples

    shared_examples 'should implement the TypeContract methods' do
      describe '::contract' do
        it 'should define the method' do
          expect(described_class).
            to respond_to(:contract).
            with(0..1).arguments.
            and_a_block
        end # it

        it 'should return an empty contract' do
          contract = described_class.contract

          expect(contract).to be_a Bronze::Contracts::Contract
          expect(contract.constraints).to satisfy(&:empty?)
        end # it

        describe 'with a contract class' do
          let(:contract_class) { Class.new(Bronze::Contracts::Contract) }

          it 'should set the contract' do
            expect { described_class.contract contract_class }.
              to change(described_class, :contract).
              to be_a contract_class
          end # it
        end # describe

        describe 'with a contract instance' do
          let(:contract) { Bronze::Contracts::Contract.new }

          it 'should set the contract' do
            expect { described_class.contract contract }.
              to change(described_class, :contract).
              to be contract
          end # it
        end # describe

        describe 'with a block' do
          it 'should execute the block in the context of the contract' do
            contract  = described_class.contract
            called_by = nil

            described_class.contract do
              called_by = self
            end # contract

            expect(called_by).to be contract
          end # it

          it 'should add the specified constraints' do
            contract = described_class.contract do
              constrain :title, :present => true

              constrain :isbn, :type => String, :nil => false
            end # contract

            constraints = contract.constraints

            expect(constraints).to include { |data|
              data.constraint.is_a?(Bronze::Constraints::PresenceConstraint) &&
                data.property == :title &&
                !data.negated?
            } # end include

            expect(constraints).to include { |data|
              data.constraint.is_a?(Bronze::Constraints::TypeConstraint) &&
                data.constraint.type == String &&
                data.property == :isbn &&
                !data.negated?
            } # end include

            expect(constraints).to include { |data|
              data.constraint.is_a?(Bronze::Constraints::NilConstraint) &&
                data.property == :isbn &&
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
              add_constraint Spec::Constraints::SuccessConstraint.new
            end # contract
          end # before example

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a contract that does not match the object' do
          let(:error_type) do
            Spec::Constraints::FailureConstraint::INVALID_ERROR
          end # let

          before(:example) do
            described_class.contract do
              add_constraint Spec::Constraints::FailureConstraint.new
            end # contract
          end # before example

          include_examples 'should return false and the errors object'
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
