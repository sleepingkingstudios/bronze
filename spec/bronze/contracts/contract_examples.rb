# spec/bronze/contracts/contract_examples.rb

require 'bronze/contracts/contract_builder_examples'

module Spec::Contracts
  module ContractExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Contracts::ContractBuilderExamples

    shared_examples 'should implement the Contract methods' do
      include_examples 'should implement the ContractBuilder methods'

      describe '::add_constraint' do
        let(:described_class) { Class.new(super()) }
        let(:prototype)       { described_class.send :prototype }

        it 'should delegate the method to the prototype' do
          expect(described_class).
            to delegate_method(:add_constraint).
            to(prototype).
            with_arguments(double('constraint')).
            and_keywords(:on => :property_name)
        end # it
      end # describe

      describe '::constrain' do
        let(:described_class) { Class.new(super()) }
        let(:prototype)       { described_class.send :prototype }

        it 'should delegate the method to the prototype' do
          expect(described_class).
            to delegate_method(:constrain).
            to(prototype).
            with_arguments(:property_name, :present => true)
        end # it
      end # describe

      describe '::constraints' do
        it 'should define the class reader' do
          expect(described_class).
            to have_reader(:constraints).
            with_value(be == [])
        end # it
      end # describe

      describe '#constraints' do
        include_examples 'should have reader', :constraints, ->() { be == [] }
      end # describe

      describe '#empty?' do
        it { expect(instance).to respond_to(:empty?).with(0).arguments }

        it { expect(instance.empty?).to be true }

        context 'when there are constraints on the contract' do
          before(:example) do
            constraint_class = Spec::Constraints::SuccessConstraint

            instance.add_constraint constraint_class.new
          end # before

          it { expect(instance.empty?).to be false }
        end # context

        context 'when there are constraints on the class' do
          let(:described_class) { Class.new(super()) }

          before(:example) do
            constraint_class = Spec::Constraints::SuccessConstraint

            described_class.add_constraint constraint_class.new
          end # before example

          it { expect(instance.empty?).to be false }
        end # context

        context 'when there are constraints on the parent class' do
          let(:described_class) { Class.new(super()) }
          let(:child_class)     { Class.new(described_class) }
          let(:instance)        { child_class.new }

          before(:example) do
            constraint_class = Spec::Constraints::SuccessConstraint

            described_class.add_constraint constraint_class.new
          end # before example

          it { expect(instance.empty?).to be false }
        end # context
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
          let(:error_type) do
            Spec::Constraints::FailureConstraint::INVALID_ERROR
          end # let

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
          let(:error_type) do
            Spec::Constraints::FailureConstraint::INVALID_ERROR
          end # let

          before(:example) do
            constraint_class = Spec::Constraints::FailureConstraint

            3.times { instance.add_constraint constraint_class.new }
          end # before example

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 3

              errors.each { |error| expect(error[:type]).to be == error_type }
            } # end lambda
        end # context

        context 'when there are mixed matching and non-matching constraints' do
          let(:error_type) do
            Spec::Constraints::FailureConstraint::INVALID_ERROR
          end # let

          before(:example) do
            constraint_class = Spec::Constraints::SuccessConstraint

            3.times { instance.add_constraint constraint_class.new }

            constraint_class = Spec::Constraints::FailureConstraint

            3.times { instance.add_constraint constraint_class.new }
          end # before example

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 3

              errors.each { |error| expect(error[:type]).to be == error_type }
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

              errors.each { |error| expect(error[:type]).to be == error_type }
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

              errors.each { |error| expect(error[:type]).to be == error_type }
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

              errors.each { |error| expect(error[:type]).to be == error_type }
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

              errors.each { |error| expect(error[:type]).to be == error_type }
            } # end lambda
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
