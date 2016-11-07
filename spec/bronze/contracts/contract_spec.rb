# spec/bronze/contracts/contract_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'
require 'bronze/constraints/type_constraint'
require 'bronze/contracts/contract'
require 'bronze/entities/entity'

RSpec.describe Bronze::Contracts::Contract do
  include Spec::Constraints::ConstraintsExamples

  shared_examples 'should add the constraint' do
    let(:constraint) { Spec::Constraints::SuccessConstraint.new }

    it 'should add the constraint' do
      expect { contract.add_constraint constraint }.
        to change(contract, :constraints).
        to include { |data|
          data.constraint == constraint &&
            data.negated? == false
        } # end include
    end # it

    describe 'with :if => proc' do
      let(:condition) { ->(obj) {} }

      it 'should add the constraint' do
        expect { contract.add_constraint constraint, :if => condition }.
          to change(contract, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.if_condition == condition
          } # end include
      end # it
    end # describe

    describe 'with :negated => true' do
      it 'should add the constraint' do
        expect { contract.add_constraint constraint, :negated => true }.
          to change(contract, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.negated? == true
          } # end include
      end # it
    end # describe

    describe 'with :on => property' do
      let(:property) { :supply_limit }

      it 'should add the constraint' do
        expect { contract.add_constraint constraint, :on => property }.
          to change(contract, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.property == property
          } # end include
      end # it
    end # describe

    describe 'with :unless => proc' do
      let(:condition) { ->(obj) {} }

      it 'should add the constraint' do
        expect { contract.add_constraint constraint, :unless => condition }.
          to change(contract, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.unless_condition == condition
          } # end include
      end # it
    end # describe
  end # shared_examples

  shared_examples 'should create and add the constraint' do
    desc = 'should create and add the specified constraint'
    shared_examples desc do |constraint_type, expected = {}|
      it 'should create and add the constraint' do
        expect { contract.constrain(property, params) }.
          to change(contract.constraints, :count).by(1)

        context = contract.constraints.last
        expect(context.negated?).to be !!expected[:negated]
        expect(context.property).to be == property
        expect(context.constraint).to be_a constraint_type

        condition = expected[:if_condition] ? proc : nil
        expect(context.if_condition).to be condition

        condition = expected[:unless_condition] ? proc : nil
        expect(context.unless_condition).to be condition
      end # it
    end # shared_examples

    desc = 'should create and add the constraint with options'
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

        include_examples 'should create and add the constraint with options',
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

        include_examples 'should create and add the constraint with options',
          Bronze::Contracts::Contract
      end # describe

      describe 'with an object with a #contract method' do
        let(:contract)   { Bronze::Contracts::Contract.new }
        let(:constraint) { double('object', :contract => contract) }
        let(:params)     { constraint }

        include_examples 'should create and add the specified constraint',
          Bronze::Contracts::Contract

        include_examples 'should create and add the constraint with options',
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

        include_examples 'should create and add the constraint with options',
          Bronze::Constraints::PresenceConstraint
      end # describe

      describe 'with a block' do
        it 'should create a child contract' do
          defn = ->() { constrain :subtitle, :type => String }

          expect { contract.constrain(property, &defn) }.
            to change(contract.constraints, :count).by(1)

          context = contract.constraints.last
          expect(context.negated?).to be false
          expect(context.property).to be == property
          expect(context.constraint).to be_a Bronze::Contracts::Contract

          child   = context.constraint
          context = child.constraints.last
          expect(context.negated?).to be false
          expect(context.property).to be == :subtitle
          expect(context.constraint).to be_a Bronze::Constraints::TypeConstraint
          expect(context.constraint.type).to be == String
        end # it
      end # describe
    end # shared_examples

    let(:constraints) { {} }
    let(:property)    { nil }

    include_examples 'should create the constraint(s)'

    describe 'with a property name' do
      let(:property) { :name }

      include_examples 'should create the constraint(s)'
    end # describe
  end # shared_examples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::add_constraint' do
    let(:contract) { Class.new(described_class) }

    it 'should define the method' do
      expect(described_class).
        to respond_to(:add_constraint).
        with(1).argument.
        and_any_keywords
    end # let

    include_examples 'should add the constraint'
  end # describe

  describe '::constrain' do
    let(:contract) { Class.new(described_class) }

    it 'should define the method' do
      expect(described_class).
        to respond_to(:constrain).
        with(0..2).arguments.
        and_a_block
    end # let

    it { expect(described_class).to alias_method(:constrain).as(:validate) }

    include_examples 'should create and add the constraint'
  end # describe

  describe '::constraints' do
    it 'should define the class reader' do
      expect(described_class).to have_reader(:constraints).with_value(be == [])
    end # it
  end # describe

  describe '#add_constraint' do
    let(:contract) { instance }

    it 'should define the method' do
      expect(instance).
        to respond_to(:add_constraint).
        with(1).argument.
        and_any_keywords
    end # let

    include_examples 'should add the constraint'
  end # describe

  describe '#constraints' do
    include_examples 'should have reader', :constraints, ->() { be == [] }
  end # describe

  describe '#empty?' do
    it { expect(instance).to respond_to(:empty?).with(0).arguments }

    it { expect(instance.empty?).to be true }

    pending
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    include_examples 'should return true and an empty errors object'

    context 'when there is one matching constraint' do
      before(:example) do
        constraint = Spec::Constraints::SuccessConstraint.new

        instance.add_constraint constraint
      end # before example

      include_examples 'should return true and an empty errors object'
    end # context

    context 'when there is one non-matching constraint' do
      let(:error_type) { Spec::Constraints::FailureConstraint::INVALID_ERROR }

      before(:example) do
        constraint = Spec::Constraints::FailureConstraint.new

        instance.add_constraint constraint
      end # before example

      include_examples 'should return false and the errors object'
    end # context

    context 'when there are many matching constraints' do
      before(:example) do
        constraint_class = Spec::Constraints::SuccessConstraint

        3.times { instance.add_constraint constraint_class.new }
      end # before example

      include_examples 'should return true and an empty errors object'
    end # context

    context 'when there are many non-matching constraints' do
      let(:error_type) { Spec::Constraints::FailureConstraint::INVALID_ERROR }

      before(:example) do
        constraint_class = Spec::Constraints::FailureConstraint

        3.times { instance.add_constraint constraint_class.new }
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 3

          errors.each { |error| expect(error.type).to be == error_type }
        } # end lambda
    end # context

    context 'when there are mixed matching and non-matching constraints' do
      let(:error_type) { Spec::Constraints::FailureConstraint::INVALID_ERROR }

      before(:example) do
        constraint_class = Spec::Constraints::SuccessConstraint

        3.times { instance.add_constraint constraint_class.new }

        constraint_class = Spec::Constraints::FailureConstraint

        3.times { instance.add_constraint constraint_class.new }
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 3

          errors.each { |error| expect(error.type).to be == error_type }
        } # end lambda
    end # context

    context 'when there are constraints on the class' do
      let(:described_class) { Class.new(super()) }
      let(:child_class)     { Class.new(described_class) }
      let(:instance)        { child_class.new }
      let(:error_type) do
        Spec::Constraints::FailureConstraint::INVALID_ERROR
      end # let

      before(:example) do
        constraint_class = Spec::Constraints::FailureConstraint

        described_class.add_constraint constraint_class.new
        child_class.add_constraint     constraint_class.new
        instance.add_constraint        constraint_class.new
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 3

          errors.each { |error| expect(error.type).to be == error_type }
        } # end lambda
    end # context
  end # describe

  describe '#negated_match' do
    let(:error_type)   { Spec::Constraints::SuccessConstraint::VALID_ERROR }
    let(:match_method) { :negated_match }
    let(:object)       { double('object') }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    include_examples 'should return true and an empty errors object'

    context 'when there is one matching constraint' do
      before(:example) do
        constraint = Spec::Constraints::SuccessConstraint.new

        instance.add_constraint constraint
      end # before example

      include_examples 'should return false and the errors object'
    end # context

    context 'when there is one non-matching constraint' do
      before(:example) do
        constraint = Spec::Constraints::FailureConstraint.new

        instance.add_constraint constraint
      end # before example

      include_examples 'should return true and an empty errors object'
    end # context

    context 'when there are many matching constraints' do
      before(:example) do
        constraint_class = Spec::Constraints::SuccessConstraint

        3.times { instance.add_constraint constraint_class.new }
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 3

          errors.each { |error| expect(error.type).to be == error_type }
        } # end lambda
    end # context

    context 'when there are many non-matching constraints' do
      before(:example) do
        constraint_class = Spec::Constraints::FailureConstraint

        3.times { instance.add_constraint constraint_class.new }
      end # before example

      include_examples 'should return true and an empty errors object'
    end # context

    context 'when there are mixed matching and non-matching constraints' do
      before(:example) do
        constraint_class = Spec::Constraints::SuccessConstraint

        3.times { instance.add_constraint constraint_class.new }

        constraint_class = Spec::Constraints::FailureConstraint

        3.times { instance.add_constraint constraint_class.new }
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 3

          errors.each { |error| expect(error.type).to be == error_type }
        } # end lambda
    end # context

    context 'when there are constraints on the class' do
      let(:described_class) { Class.new(super()) }
      let(:child_class)     { Class.new(described_class) }
      let(:instance)        { child_class.new }
      let(:error_type) do
        Spec::Constraints::SuccessConstraint::VALID_ERROR
      end # let

      before(:example) do
        constraint_class = Spec::Constraints::SuccessConstraint

        described_class.add_constraint constraint_class.new
        child_class.add_constraint     constraint_class.new
        instance.add_constraint        constraint_class.new
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 3

          errors.each { |error| expect(error.type).to be == error_type }
        } # end lambda
    end # context
  end # describe
end # describe
