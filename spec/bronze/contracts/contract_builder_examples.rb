# spec/bronze/contracts/contract_builder_examples.rb

require 'bronze/constraints/constraint'
require 'bronze/contracts/contract'

module Spec::Contracts
  module ContractBuilderExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the ContractBuilder methods' do
      describe '#add_constraint' do
        it 'should delegate the method to the contract' do
          constraint = double('constraint')
          params     = { :on => :attribute, :negated => true }

          expect(instance.contract).
            to receive(:add_constraint).
            with(constraint, params)

          instance.add_constraint constraint, params
        end # it
      end # describe

      describe '#constrain' do
        shared_examples 'should add the constraints to the contract' do
          describe 'with an unknown constraint type' do
            it 'should raise an error' do
              error_types = Bronze::Constraints::ConstraintBuilder

              expect { instance.build_constraint :unknown, {} }.
                to raise_error error_types::UNKNOWN_CONSTRAINT,
                  'unrecognized constraint type "unknown"'
            end # it
          end # describe

          describe 'with a known constraint type' do
            let(:key)        { :name }
            let(:params)     { { :value => double('value') } }
            let(:constraint) { double('constraint') }

            before(:example) do
              expect(instance).
                to receive(:build_constraint).
                with(key, params).
                and_return(constraint)
            end # before example

            it 'should delegate to the builder method' do
              constraints = instance.contract.constraints

              expect { instance.constrain(property, key => params) }.
                to change(constraints, :count).by(1)

              data = constraints.last
              expect(data.nesting).to be == nesting
              expect(data.negated?).to be false

              expect(data.constraint).to be constraint
            end # it

            describe 'with :negated => true' do
              let(:params) { super().merge :negated => true }

              it 'should delegate to the builder method' do
                constraints = instance.contract.constraints

                expect { instance.constrain(property, key => params) }.
                  to change(constraints, :count).by(1)

                data = constraints.last
                expect(data.nesting).to be == nesting
                expect(data.negated?).to be true

                expect(data.constraint).to be constraint
              end # it
            end # describe
          end # describe

          describe 'with a constraint object' do
            let(:constraint) { Bronze::Constraints::Constraint.new }

            it 'should add the constraint' do
              constraints = instance.contract.constraints

              expect { instance.constrain(property, constraint => true) }.
                to change(constraints, :count).by(1)

              data = constraints.last
              expect(data.nesting).to be == nesting
              expect(data.negated?).to be false

              expect(data.constraint).to be constraint
            end # it

            describe 'with constraint => false' do
              it 'should add the constraint' do
                constraints = instance.contract.constraints

                expect { instance.constrain(property, constraint => false) }.
                  to change(constraints, :count).by(1)

                data = constraints.last
                expect(data.nesting).to be == nesting
                expect(data.negated?).to be true

                expect(data.constraint).to be constraint
              end # it
            end # describe
          end # describe

          describe 'with a block' do
            it 'should create a child contract' do
              constraints = instance.contract.constraints

              defn = lambda do
                instance.constrain property do
                  constrain :subtitle, :type => String
                end # constrain
              end # lambda

              expect(&defn).to change(constraints, :count).by(1)

              data = constraints.last

              expect(data.nesting).to be == nesting
              expect(data.negated?).to be false

              child = data.constraint

              expect(child).to be_a Bronze::Contracts::Contract

              constraints = child.constraints
              expect(constraints.count).to be 1

              data = constraints.last

              expect(data.nesting).to be == [:subtitle]
              expect(data.negated?).to be false

              expect(data.constraint).to be_a Bronze::Constraints::Constraint
            end # it
          end # describe
        end # shared_examples

        let(:property) { nil }
        let(:nesting)  { [] }

        it 'should define the method' do
          expect(instance).
            to respond_to(:constrain).
            with(0..2).arguments.
            and_a_block
        end # it

        describe 'with nil' do
          it 'should raise an error' do
            expect { instance.constrain nil }.
              to raise_error described_class::EMPTY_CONSTRAINTS,
                'must specify at least one constraint type'
          end # it
        end # describe

        include_examples 'should add the constraints to the contract'

        describe 'with a property name' do
          let(:property) { :title }
          let(:nesting)  { [property] }

          include_examples 'should add the constraints to the contract'
        end # describe
      end # describe

      describe '#contract' do
        include_examples 'should have reader', :contract,
          ->() { be_a Bronze::Contracts::Contract }

        context 'when there is an existing contract' do
          let(:contract) { Bronze::Contracts::Contract.new }

          it { expect(instance.contract).to be contract }
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
