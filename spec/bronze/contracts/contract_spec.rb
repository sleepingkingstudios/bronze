# spec/bronze/contracts/contract_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/empty_constraint'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/nil_constraint'
require 'bronze/constraints/success_constraint'
require 'bronze/constraints/type_constraint'
require 'bronze/contracts/contract'
require 'bronze/entities/entity'

RSpec.describe Bronze::Contracts::Contract do
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
          data.constraint == constraint &&
            data.negated? == false
        } # end include
    end # it

    describe 'with :on => a nesting with one item' do
      let(:nesting) { [:supply_limit] }

      it 'should add the constraint' do
        expect { instance.add_constraint constraint, :negated => true }.
          to change(instance, :constraints).
          to include { |data|
            data.constraint == constraint &&
              data.negated? == true
          } # end include
      end # it
    end # describe

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
    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with a simple object' do
      let(:object) { double('object') }

      include_examples 'should return true and an empty errors object'

      context 'with a matching constraint' do
        before(:example) do
          instance.add_constraint Spec::SuccessConstraint.new
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated matching constraint' do
        let(:error_type) { Spec::SuccessConstraint::VALID_ERROR }

        before(:example) do
          instance.add_constraint Spec::SuccessConstraint.new, :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching constraint' do
        let(:error_type) { Spec::FailureConstraint::INVALID_ERROR }

        before(:example) do
          instance.add_constraint Spec::FailureConstraint.new
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated non-matching constraint' do
        before(:example) do
          constraint = Spec::FailureConstraint.new

          instance.add_constraint constraint, :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with many matching constraints' do
        before(:example) do
          3.times do
            instance.add_constraint Spec::SuccessConstraint.new
          end # times
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with many non-matching constraints' do
        let(:error_types) do
          [
            'constraints.errors.first_error',
            'constraints.errors.second_error',
            'constraints.errors.third_error'
          ] # end array
        end # let

        before(:example) do
          error_types.each do |error_type|
            constraint = Spec::FailureConstraint.new error_type

            instance.add_constraint constraint
          end # each
        end # before example

        include_examples 'should return false and the errors object',
          lambda { |errors|
            expect(errors.count).to be == 3

            error_types.each do |error_type|
              expect(errors).to include { |error|
                error.type == error_type
              } # include
            end # each
          } # end lambda
      end # context

      context 'with mixed matching and non-matching constraints' do
        let(:error_types) do
          [
            'constraints.errors.first_error',
            'constraints.errors.second_error',
            'constraints.errors.third_error'
          ] # end array
        end # let

        before(:example) do
          3.times do
            instance.add_constraint Spec::SuccessConstraint.new
          end # times

          error_types.each do |error_type|
            constraint = Spec::FailureConstraint.new error_type

            instance.add_constraint constraint
          end # each
        end # before example

        include_examples 'should return false and the errors object',
          lambda { |errors|
            expect(errors.count).to be == 3

            error_types.each do |error_type|
              expect(errors).to include { |error|
                error.type == error_type
              } # include
            end # each
          } # end lambda
      end # context
    end # describe

    describe 'with an object with attributes' do
      let(:object_class) do
        Class.new do
          def initialize title
            @title = title
          end # method initialize

          attr_reader :title
        end # class
      end # let
      let(:object) { object_class.new('Object Title') }

      include_examples 'should return true and an empty errors object'

      context 'with a matching constraint on an undefined attribute' do
        before(:example) do
          constraint = Bronze::Constraints::NilConstraint.new

          instance.add_constraint constraint, :on => :subtitle
        end # before

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching constraint on an undefined attribute' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => Integer } }
        let(:error_nesting) { [:subtitle] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(Integer)

          instance.add_constraint constraint, :on => :subtitle
        end # before

        include_examples 'should return false and the errors object'
      end # context

      context 'with a matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint, :on => :title
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => String } }
        let(:error_nesting) { [:title] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint, :on => :title, :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::EmptyConstraint::NOT_EMPTY_ERROR
        end # let
        let(:error_nesting) { [:title] }

        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint, :on => :title
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated non-matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint, :on => :title, :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context
    end # describe

    describe 'with an object with attributes hashes' do
      let(:object) { Struct.new(:data).new(:name => 'Object Name') }

      include_examples 'should return true and an empty errors object'

      context 'with a matching constraint on an undefined attribute' do
        before(:example) do
          constraint = Bronze::Constraints::NilConstraint.new

          instance.add_constraint constraint, :on => [:data, :slug]
        end # before

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching constraint on an undefined attribute' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => Integer } }
        let(:error_nesting) { [:data, :slug] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(Integer)

          instance.add_constraint constraint, :on => [:data, :slug]
        end # before

        include_examples 'should return false and the errors object'
      end # context

      context 'with a matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint, :on => [:data, :name]
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => String } }
        let(:error_nesting) { [:data, :name] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint,
            :on      => [:data, :name],
            :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::EmptyConstraint::NOT_EMPTY_ERROR
        end # let
        let(:error_nesting) { [:data, :name] }

        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint, :on => [:data, :name]
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated non-matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint,
            :on      => [:data, :name],
            :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context
    end # describe

    describe 'with an object with children' do
      let(:address)   { Struct.new(:street).new('Falken Avenue') }
      let(:publisher) { Struct.new(:address).new(address) }
      let(:object)    { Struct.new(:publisher).new(publisher) }

      include_examples 'should return true and an empty errors object'

      context 'with a matching child attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint,
            :on => [:publisher, :address, :street]
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => String } }
        let(:error_nesting) { [:publisher, :address, :street] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint,
            :on      => [:publisher, :address, :street],
            :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::EmptyConstraint::NOT_EMPTY_ERROR
        end # let
        let(:error_nesting) { [:publisher, :address, :street] }

        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint,
            :on => [:publisher, :address, :street]
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated non-matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint,
            :on      => [:publisher, :address, :street],
            :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    describe 'with a simple object' do
      let(:object) { double('object') }

      include_examples 'should return true and an empty errors object'

      context 'with a matching constraint' do
        let(:error_type) { Spec::SuccessConstraint::VALID_ERROR }

        before(:example) do
          instance.add_constraint Spec::SuccessConstraint.new
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated matching constraint' do
        before(:example) do
          instance.add_constraint Spec::SuccessConstraint.new, :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching constraint' do
        before(:example) do
          instance.add_constraint Spec::FailureConstraint.new
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated non-matching constraint' do
        let(:error_type) { Spec::FailureConstraint::INVALID_ERROR }

        before(:example) do
          constraint = Spec::FailureConstraint.new

          instance.add_constraint constraint, :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with many matching constraints' do
        before(:example) do
          3.times do
            instance.add_constraint Spec::SuccessConstraint.new
          end # times
        end # before example

        include_examples 'should return false and the errors object',
          lambda { |errors|
            expect(errors.count).to be == 3

            errors.each do |error|
              expect(error.type).to be == Spec::SuccessConstraint::VALID_ERROR
            end # each
          } # end lambda
      end # context

      context 'with many non-matching constraints' do
        let(:error_types) do
          [
            'constraints.errors.first_error',
            'constraints.errors.second_error',
            'constraints.errors.third_error'
          ] # end array
        end # let

        before(:example) do
          error_types.each do |error_type|
            constraint = Spec::FailureConstraint.new error_type

            instance.add_constraint constraint
          end # each
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with mixed matching and non-matching constraints' do
        let(:error_types) do
          [
            'constraints.errors.first_error',
            'constraints.errors.second_error',
            'constraints.errors.third_error'
          ] # end array
        end # let

        before(:example) do
          3.times do
            instance.add_constraint Spec::SuccessConstraint.new
          end # times

          error_types.each do |error_type|
            constraint = Spec::FailureConstraint.new error_type

            instance.add_constraint constraint
          end # each
        end # before example

        include_examples 'should return false and the errors object',
          lambda { |errors|
            expect(errors.count).to be == 3

            errors.each do |error|
              expect(error.type).to be == Spec::SuccessConstraint::VALID_ERROR
            end # each
          } # end lambda
      end # context
    end # describe

    describe 'with an object with attributes' do
      let(:object_class) do
        Class.new do
          def initialize title
            @title = title
          end # method initialize

          attr_reader :title
        end # class
      end # let
      let(:object) { object_class.new('Object Title') }

      include_examples 'should return true and an empty errors object'

      context 'with a matching constraint on an undefined attribute' do
        let(:error_type) do
          Bronze::Constraints::NilConstraint::NIL_ERROR
        end # let
        let(:error_nesting) { [:subtitle] }

        before(:example) do
          constraint = Bronze::Constraints::NilConstraint.new

          instance.add_constraint constraint, :on => :subtitle
        end # before

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching constraint on an undefined attribute' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(Integer)

          instance.add_constraint constraint, :on => :subtitle
        end # before

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => String } }
        let(:error_nesting) { [:title] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint, :on => :title
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint, :on => :title, :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint, :on => :title
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated non-matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::EmptyConstraint::NOT_EMPTY_ERROR
        end # let
        let(:error_nesting) { [:title] }

        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint, :on => :title, :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context
    end # describe

    describe 'with an object with attributes hashes' do
      let(:object) { Struct.new(:data).new(:name => 'Object Name') }

      include_examples 'should return true and an empty errors object'

      context 'with a matching constraint on an undefined attribute' do
        let(:error_type) do
          Bronze::Constraints::NilConstraint::NIL_ERROR
        end # let
        let(:error_nesting) { [:data, :slug] }

        before(:example) do
          constraint = Bronze::Constraints::NilConstraint.new

          instance.add_constraint constraint, :on => [:data, :slug]
        end # before

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching constraint on an undefined attribute' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(Integer)

          instance.add_constraint constraint, :on => [:data, :slug]
        end # before

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => String } }
        let(:error_nesting) { [:data, :name] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint, :on => [:data, :name]
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint,
            :on      => [:data, :name],
            :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint, :on => [:data, :name]
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated non-matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::EmptyConstraint::NOT_EMPTY_ERROR
        end # let
        let(:error_nesting) { [:data, :name] }

        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint,
            :on      => [:data, :name],
            :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context
    end # describe

    describe 'with an object with children' do
      let(:address)   { Struct.new(:street).new('Falken Avenue') }
      let(:publisher) { Struct.new(:address).new(address) }
      let(:object)    { Struct.new(:publisher).new(publisher) }

      include_examples 'should return true and an empty errors object'

      context 'with a matching child attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params)  { { :value => String } }
        let(:error_nesting) { [:publisher, :address, :street] }

        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint,
            :on => [:publisher, :address, :street]
        end # before example

        include_examples 'should return false and the errors object'
      end # context

      context 'with a negated matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::TypeConstraint.new(String)

          instance.add_constraint constraint,
            :on      => [:publisher, :address, :street],
            :negated => true
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching attribute constraint' do
        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint,
            :on => [:publisher, :address, :street]
        end # before example

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a negated non-matching attribute constraint' do
        let(:error_type) do
          Bronze::Constraints::EmptyConstraint::NOT_EMPTY_ERROR
        end # let
        let(:error_nesting) { [:publisher, :address, :street] }

        before(:example) do
          constraint = Bronze::Constraints::EmptyConstraint.new

          instance.add_constraint constraint,
            :on      => [:publisher, :address, :street],
            :negated => true
        end # before example

        include_examples 'should return false and the errors object'
      end # context
    end # describe
  end # describe
end # describe
