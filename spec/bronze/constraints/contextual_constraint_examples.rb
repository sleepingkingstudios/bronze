# spec/bronze/constraints/contextual_constraint_examples.rb

require 'bronze/constraints/constraint_examples'

module Spec::Constraints
  module ContextualConstraintExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Constraints::ConstraintExamples

    shared_context 'when the constraint is negated' do
      let(:params) { super().merge :negated => true }
    end # shared_context

    shared_context 'when a property name is set' do
      let(:property) { :name }
      let(:params)   { super().merge :property => property }
    end # shared_context

    shared_examples 'should implement the ContextualConstraint methods' do
      describe '#constraint' do
        include_examples 'should have reader', :constraint, ->() { constraint }
      end # describe

      describe '#if_condition' do
        include_examples 'should have reader', :if_condition, nil

        context 'when an if condition is defined' do
          let(:condition) { ->() {} }
          let(:params)    { super().merge :if => condition }

          it { expect(instance.if_condition).to be condition }
        end # context
      end # describe

      describe '#negated' do
        include_examples 'should have reader', :negated, false

        wrap_context 'when the constraint is negated' do
          it { expect(instance.negated).to be true }
        end # wrap_context
      end # describe

      describe '#negated?' do
        include_examples 'should have predicate', :negated?, false

        wrap_context 'when the constraint is negated' do
          it { expect(instance.negated?).to be true }
        end # wrap_context
      end # describe

      describe '#property' do
        include_examples 'should have reader', :property, nil

        wrap_context 'when a property name is set' do
          it { expect(instance.property).to be == property }
        end # wrap_context
      end # describe

      describe '#unless_condition' do
        include_examples 'should have reader', :unless_condition, nil

        context 'when an unless conditional is defined' do
          let(:conditional) { ->() {} }
          let(:params)      { super().merge :unless => conditional }

          it { expect(instance.unless_condition).to be conditional }
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
