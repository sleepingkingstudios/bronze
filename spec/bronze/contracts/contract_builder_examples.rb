# spec/bronze/contracts/contract_builder_examples.rb

require 'bronze/constraints/constraint_examples'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'
require 'bronze/constraints/type_constraint'

module Spec::Contracts
  module ContractBuilderExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Constraints::ConstraintExamples

    shared_examples 'should implement the ContractBuilder methods' do
      describe '#add_constraint' do
        let(:constraint) { Spec::Constraints::SuccessConstraint.new }

        it 'should define the method' do
          expect(instance).
            to respond_to(:add_constraint).
            with(1).argument.
            and_any_keywords
        end # let

        it 'should add the constraint' do
          expect { instance.add_constraint constraint }.
            to change(instance, :constraints).
            to include { |data|
              data.constraint == constraint &&
                data.negated? == false
            } # end include
        end # it

        describe 'with :if => proc' do
          let(:condition) { ->(obj) {} }

          it 'should add the constraint' do
            expect { instance.add_constraint constraint, :if => condition }.
              to change(instance, :constraints).
              to include { |data|
                data.constraint == constraint &&
                  data.if_condition == condition
              } # end include
          end # it
        end # describe

        describe 'with :negated => true' do
          it 'should add the constraint' do
            expect { instance.add_constraint constraint, :negated => true }.
              to change(instance, :constraints).
              to include { |data|
                data.constraint == constraint &&
                  data.negated? == true
              } # end include
          end # it
        end # describe

        describe 'with :on => property' do
          let(:property) { :supply_limit }

          it 'should add the constraint' do
            expect { instance.add_constraint constraint, :on => property }.
              to change(instance, :constraints).
              to include { |data|
                data.constraint == constraint &&
                  data.property == property
              } # end include
          end # it
        end # describe

        describe 'with :unless => proc' do
          let(:condition) { ->(obj) {} }

          it 'should add the constraint' do
            expect { instance.add_constraint constraint, :unless => condition }.
              to change(instance, :constraints).
              to include { |data|
                data.constraint == constraint &&
                  data.unless_condition == condition
              } # end include
          end # it
        end # describe
      end # describe

      describe '#constrain' do
        desc = 'should create and add the specified constraint'
        shared_examples desc do |constraint_type, expected = {}|
          it 'should create and add the constraint' do
            expect { instance.constrain(property, params) }.
              to change(instance.constraints, :count).by(1)

            context = instance.constraints.last
            expect(context.negated?).to be !!expected[:negated]
            expect(context.property).to be == property
            expect(context.constraint).to be_a constraint_type

            condition = expected[:if_condition] ? proc : nil
            expect(context.if_condition).to be condition

            condition = expected[:unless_condition] ? proc : nil
            expect(context.unless_condition).to be condition
          end # it
        end # shared_examples

        desc = 'should create constraints with options'
        shared_examples desc do |constraint_type|
          describe 'with constraint => true' do
            let(:params) { { constraint => true } }

            include_examples 'should create and add the specified constraint',
              constraint_type
          end # describe

          describe 'with constraint => false' do
            let(:params) { { constraint => false } }

            include_examples 'should create and add the specified constraint',
              constraint_type,
              :negated => true
          end # describe

          describe 'with constraint => { :if => proc }' do
            let(:proc)   { ->() {} }
            let(:params) { { constraint => { :if => proc } } }

            include_examples 'should create and add the specified constraint',
              constraint_type,
              :if_condition => true
          end # describe

          describe 'with constraint => { :negated => true }' do
            let(:params) { { constraint => { :negated => true } } }

            include_examples 'should create and add the specified constraint',
              constraint_type,
              :negated => true
          end # describe

          describe 'with constraint => { :unless => proc }' do
            let(:proc)   { ->() {} }
            let(:params) { { constraint => { :unless => proc } } }

            include_examples 'should create and add the specified constraint',
              constraint_type,
              :unless_condition => true
          end # describe
        end # shared_examples

        shared_examples 'should create the constraint(s)' do
          describe 'with no arguments' do
            it 'should raise an error' do
              expect { instance.constrain property }.
                to raise_error described_class::EMPTY_CONSTRAINTS,
                  'must specify at least one constraint'
            end # it
          end # describe

          describe 'with an object' do
            let(:object) { Object.new }

            it 'should raise an error' do
              error_types = Bronze::Constraints::ConstraintBuilder

              expect { instance.constrain property, object }.
                to raise_error error_types::INVALID_CONSTRAINT,
                  "#{object} is not a valid constraint"
            end # it
          end # describe

          describe 'with a constraint object' do
            let(:constraint) { Bronze::Constraints::Constraint.new }
            let(:params)     { constraint }

            include_examples 'should create and add the specified constraint',
              Bronze::Constraints::Constraint

            include_examples 'should create constraints with options',
              Bronze::Constraints::Constraint
          end # describe

          describe 'with an object with a ::Contract constant' do
            let(:contract) { Bronze::Contracts::Contract.new }
            let(:constraint) do
              Module.new.tap do |mod|
                mod.const_set :Contract, contract
              end # tap
            end # let
            let(:params) { constraint }

            include_examples 'should create and add the specified constraint',
              Bronze::Contracts::Contract

            include_examples 'should create constraints with options',
              Bronze::Contracts::Contract
          end # describe

          describe 'with an object with a #contract method' do
            let(:contract)   { Bronze::Contracts::Contract.new }
            let(:constraint) { double('object', :contract => contract) }
            let(:params)     { constraint }

            include_examples 'should create and add the specified constraint',
              Bronze::Contracts::Contract

            include_examples 'should create constraints with options',
              Bronze::Contracts::Contract
          end # describe

          describe 'with an unknown constraint type' do
            it 'should raise an error' do
              error_types = Bronze::Constraints::ConstraintBuilder

              expect { instance.build_constraint :unknown, {} }.
                to raise_error error_types::UNKNOWN_CONSTRAINT,
                  'unrecognized constraint type "unknown"'
            end # it
          end # describe

          describe 'with a known constraint type' do
            let(:constraint) { :present }

            include_examples 'should create constraints with options',
              Bronze::Constraints::PresenceConstraint
          end # describe

          describe 'with a block' do
            it 'should create a child contract' do
              defn = ->() { constrain :subtitle, :type => String }

              expect { instance.constrain(property, &defn) }.
                to change(instance.constraints, :count).by(1)

              context = instance.constraints.last
              expect(context.negated?).to be false
              expect(context.property).to be == property
              expect(context.constraint).to be_a Bronze::Contracts::Contract

              child   = context.constraint
              context = child.constraints.last
              expect(context.negated?).to be false
              expect(context.property).to be == :subtitle
              expect(context.constraint).
                to be_a Bronze::Constraints::TypeConstraint
              expect(context.constraint.type).to be == String
            end # it
          end # describe
        end # shared_examples

        let(:constraints) { {} }
        let(:property)    { nil }

        it 'should define the method' do
          expect(instance).
            to respond_to(:constrain).
            with(0..2).arguments.
            and_a_block
        end # it

        it { expect(instance).to alias_method(:constrain).as(:validate) }

        include_examples 'should create the constraint(s)'

        describe 'with a property name' do
          let(:property) { :name }

          include_examples 'should create the constraint(s)'
        end # describe
      end # describe
    end # shared_examples
  end # module
end # module
