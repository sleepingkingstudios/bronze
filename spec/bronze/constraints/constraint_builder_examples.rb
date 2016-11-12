# spec/bronze/constraints/constraint_builder_examples.rb

module Spec::Constraints
  module ConstraintBuilderExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    desc = 'should build a constraint'
    shared_examples desc do |constraint_class, proc = nil|
      constraint_name = constraint_class.name.split('::').last
      constraint_name.gsub!(/[a-z][A-Z]/) do |match|
        "#{match[0]} #{match[1].downcase}"
      end # gsub
      constraint_name.downcase!

      constraint_name[0...0] =
        %w(a e i o u y).include?(constraint_name[0]) ? 'an ' : 'a '

      it "should build #{constraint_name}" do
        constraint = instance.send(method_name, method_params)

        expect(constraint).to be_a constraint_class

        instance_exec(constraint, &proc) if proc.is_a?(Proc)
      end # it
    end # shared_examples

    shared_examples 'should implement the ConstraintBuilder methods' do
      describe '#build_constraint' do
        it 'should define the method' do
          expect(instance).to respond_to(:build_constraint).with(2).arguments
        end # it

        describe 'with an unknown constraint type' do
          it 'should raise an error' do
            expect { instance.build_constraint :unknown, {} }.
              to raise_error described_class::UNKNOWN_CONSTRAINT,
                'unrecognized constraint type "unknown"'
          end # it
        end # describe

        describe 'with a known constraint type' do
          it 'should delegate to the builder method' do
            params     = { :value => double('value') }
            constraint = double('constraint')

            expect(instance).
              to receive(:build_equal_constraint).
              with(params).
              and_return(constraint)

            expect(instance.build_constraint :equal, params).to be constraint
          end # it
        end # describe
      end # describe

      describe '#build_empty_constraint' do
        let(:method_name)   { :build_empty_constraint }
        let(:method_params) { {} }

        it 'should define the method' do
          expect(instance).
            to respond_to(:build_empty_constraint).
            with(1).argument
        end # it

        include_examples 'should build a constraint',
          Bronze::Constraints::EmptyConstraint
      end # describe

      describe '#build_equal_constraint' do
        let(:method_name)   { :build_equal_constraint }
        let(:method_params) { {} }

        it 'should define the method' do
          expect(instance).
            to respond_to(:build_equal_constraint).
            with(1).argument
        end # it

        it 'should raise an error' do
          expect { instance.build_equal_constraint(method_params) }.
            to raise_error described_class::INVALID_CONSTRAINT,
              'must set a value to equal'
        end # it

        describe 'with :to => value' do
          let(:value)         { double('value') }
          let(:method_params) { super().merge :to => value }

          include_examples 'should build a constraint',
            Bronze::Constraints::EqualityConstraint,
            ->(constraint) { expect(constraint.value).to be value }
        end # describe

        describe 'with :value => value' do
          let(:value)         { double('value') }
          let(:method_params) { super().merge :value => value }

          include_examples 'should build a constraint',
            Bronze::Constraints::EqualityConstraint,
            ->(constraint) { expect(constraint.value).to be value }
        end # describe
      end # describe

      describe '#build_nil_constraint' do
        let(:method_name)   { :build_nil_constraint }
        let(:method_params) { {} }

        it 'should define the method' do
          expect(instance).
            to respond_to(:build_nil_constraint).
            with(1).argument
        end # it

        include_examples 'should build a constraint',
          Bronze::Constraints::NilConstraint
      end # describe

      describe '#build_present_constraint' do
        let(:method_name)   { :build_present_constraint }
        let(:method_params) { {} }

        it 'should define the method' do
          expect(instance).
            to respond_to(:build_present_constraint).
            with(1).argument
        end # it

        include_examples 'should build a constraint',
          Bronze::Constraints::PresenceConstraint
      end # describe

      describe '#build_type_constraint' do
        let(:method_name)   { :build_type_constraint }
        let(:method_params) { {} }

        it 'should define the method' do
          expect(instance).
            to respond_to(:build_type_constraint).
            with(1).argument
        end # it

        it 'should raise an error' do
          expect { instance.build_type_constraint(method_params) }.
            to raise_error described_class::INVALID_CONSTRAINT,
              'must set a type'
        end # it

        describe 'with :type => value' do
          let(:value)         { Class.new }
          let(:method_params) { super().merge :type => value }

          include_examples 'should build a constraint',
            Bronze::Constraints::TypeConstraint,
            ->(constraint) { expect(constraint.type).to be value }
        end # describe

        describe 'with :value => value' do
          let(:value)         { Class.new }
          let(:method_params) { super().merge :value => value }

          include_examples 'should build a constraint',
            Bronze::Constraints::TypeConstraint,
            ->(constraint) { expect(constraint.type).to be value }
        end # describe
      end # describe
    end # shared_examples

    shared_examples 'should implement the EntityConstraintBuilder methods' do
      describe '#build_attribute_types_constraint' do
        let(:method_name)   { :build_attribute_types_constraint }
        let(:method_params) { {} }

        it 'should define the method' do
          expect(instance).
            to respond_to(:build_attribute_types_constraint).
            with(1).argument
        end # it

        include_examples 'should build a constraint',
          Bronze::Entities::Constraints::AttributeTypesConstraint
      end # describe
    end # shared_examples
  end # module
end # module
