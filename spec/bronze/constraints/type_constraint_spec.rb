# spec/bronze/constraints/type_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/type_constraint'

RSpec.describe Bronze::Constraints::TypeConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:expected) { Object.new }
  let(:instance) { described_class.new expected }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(1).argument.
        and_keywords(:allow_nil)
    end # it
  end # describe

  describe '#match' do
    let(:error_type)   { described_class::NOT_KIND_OF_ERROR }
    let(:error_params) { [expected] }

    it { expect(instance).to respond_to(:match).with(1).argument }

    context 'when the expected object is a Module' do
      let(:expected) { Module.new }

      describe 'with nil' do
        let(:object) { nil }

        include_examples 'should return false and the errors object'

        context 'when the constraint allows nil values' do
          let(:instance) { described_class.new expected, :allow_nil => true }

          include_examples 'should return true and an empty errors object'
        end # context
      end # describe

      describe 'with an object' do
        let(:object) { Object.new }

        include_examples 'should return false and the errors object'
      end # describe

      describe 'with an object that extends the module' do
        let(:object) { Object.new.extend(expected) }

        include_examples 'should return true and an empty errors object'
      end # describe

      describe 'with an instance of a class that includes the module' do
        let(:object_class) do
          Class.new.tap { |klass| klass.send :include, expected }
        end # let
        let(:object) { object_class.new }

        include_examples 'should return true and an empty errors object'
      end # describe
    end # context

    context 'when the expected object is a Class' do
      let(:expected) { Class.new }

      describe 'with nil' do
        let(:object) { nil }

        include_examples 'should return false and the errors object'
      end # describe

      describe 'with an object' do
        let(:object) { Object.new }

        include_examples 'should return false and the errors object'
      end # describe

      describe 'with an instance of the class' do
        let(:object) { expected.new }

        include_examples 'should return true and an empty errors object'
      end # describe

      describe 'with an instance of a subclass of the class' do
        let(:object_class) { Class.new(expected) }
        let(:object)       { object_class.new }

        include_examples 'should return true and an empty errors object'
      end # describe
    end # context
  end # describe
end # describe
