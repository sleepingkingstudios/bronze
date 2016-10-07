# spec/bronze/constraints/contract_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/contract'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'

RSpec.describe Bronze::Constraints::Contract do
  include Spec::Constraints::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#add_constraint' do
    let(:constraint) { Spec::SuccessConstraint.new }

    it 'should define the method' do
      expect(instance).
        to respond_to(:add_constraint).
        with(1).argument.
        and_keywords(:on)
    end # let

    it 'should add the constraint' do
      expect { instance.add_constraint constraint }.
        to change(instance, :constraints).
        to include { |data|
          data.constraint == constraint
        } # end include
    end # it

    describe 'with :on => a nesting with one item' do
      let(:nesting) { [:supply_limit] }

      it 'should add the constraint' do
        expect { instance.add_constraint constraint, :on => nesting }.
          to change(instance, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.nesting == nesting
          } # end include
      end # it
    end # describe

    describe 'with :on => a nesting with many items' do
      let(:nesting) { [:hazards, :terran, :nuclear_launch_detected] }

      it 'should add the constraint' do
        expect { instance.add_constraint constraint, :on => nesting }.
          to change(instance, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.nesting == nesting
          } # end include
      end # it
    end # describe
  end # describe

  describe '#constraints' do
    include_examples 'should have reader', :constraints, ->() { be == [] }
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    context 'with many constraints that matches the object' do
      before(:example) do
        3.times { instance.add_constraint Spec::SuccessConstraint.new }
      end # before example

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with many constraints that do not match the object' do
      before(:example) do
        3.times { instance.add_constraint Spec::FailureConstraint.new }
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be == 3

          expect(errors).to include { |error|
            error.type == Spec::FailureConstraint::INVALID_ERROR
          } # include
        } # end lambda
    end # context

    context 'with many constraints that partially match the object' do
      before(:example) do
        3.times { instance.add_constraint Spec::SuccessConstraint.new }

        3.times { instance.add_constraint Spec::FailureConstraint.new }
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be == 3

          expect(errors).to include { |error|
            error.type == Spec::FailureConstraint::INVALID_ERROR
          } # include
        } # end lambda
    end # context

    context 'with many constraints with nestings' do
      before(:example) do
        constraint = Spec::FailureConstraint.new :no_database_connection
        instance.add_constraint constraint

        constraint = Spec::FailureConstraint.new :not_authorized
        instance.add_constraint constraint, :on => :articles

        constraint = Spec::FailureConstraint.new :not_nil
        instance.add_constraint constraint, :on => [:articles, 1, :title]
      end # before example

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors).to include { |error|
            error.type == :no_database_connection &&
              error.nesting == []
          } # include

          expect(errors).to include { |error|
            error.type == :not_authorized &&
              error.nesting == [:articles]
          } # include

          expect(errors).to include { |error|
            error.type == :not_nil &&
              error.nesting == [:articles, 1, :title]
          } # include
        } # end lambda
    end # context
  end # describe
end # describe
