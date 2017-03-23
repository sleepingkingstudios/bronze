# spec/bronze/constraints/constraint_spec.rb

require 'bronze/constraints/constraint'
require 'bronze/constraints/constraint_examples'
require 'bronze/errors'

RSpec.describe Bronze::Constraints::Constraint do
  include Spec::Constraints::ConstraintExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1..2).arguments }

    it 'should raise an error' do
      expect { instance.send :match, object }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :matches_object?"
    end # it

    describe 'with an object that does not match the constraint' do
      let(:generated_errors) { double('generated errors') }

      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(false)
      end # before

      it 'should return false and the errors object' do
        allow(instance).to receive(:build_errors).and_return(generated_errors)

        result, errors = instance.match object

        expect(result).to be false
        expect(errors).to be generated_errors
      end # it

      describe 'with an errors object' do
        let(:passed_errors) { double('passed errors') }

        it 'should return false and the errors object' do
          result, errors = instance.match object, passed_errors

          expect(result).to be false
          expect(errors).to be passed_errors
        end # it
      end # describe
    end # describe

    describe 'with an object that matches the constraint' do
      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(true)
      end # before

      include_examples 'should return true and an empty errors object'
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:object)       { double('object') }

    it { expect(instance).to respond_to(:negated_match).with(1..2).arguments }

    it { expect(instance).to alias_method(:negated_match).as(:does_not_match) }

    it 'should raise an error' do
      expect { instance.send :negated_match, object }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :matches_object?"
    end # it

    describe 'with an object that does not match the constraint' do
      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(false)
      end # before

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an object that matches the constraint' do
      let(:generated_errors) { double('generated errors') }

      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(true)
      end # before

      it 'should return false and the errors object' do
        allow(instance).to receive(:build_negated_errors).
          and_return(generated_errors)

        result, errors = instance.negated_match object

        expect(result).to be false
        expect(errors).to be generated_errors
      end # it

      describe 'with an errors object' do
        let(:passed_errors) { double('passed errors') }

        it 'should return false and the errors object' do
          result, errors = instance.negated_match object, passed_errors

          expect(result).to be false
          expect(errors).to be passed_errors
        end # it
      end # describe
    end # describe
  end # describe
end # describe
