# spec/bronze/constraints/constraint_spec.rb

require 'bronze/constraints/constraint'
require 'bronze/constraints/constraints_examples'
require 'bronze/errors/errors'

RSpec.describe Bronze::Constraints::Constraint do
  include Spec::Constraints::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    it 'should raise an error' do
      expect { instance.send :match, object }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :matches_object?"
    end # it

    describe 'with an object that does not match the constraint' do
      let(:errors) { double('errors') }

      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(false)
        allow(instance).to receive(:build_errors).and_return(errors)
      end # before

      it 'should return false and the errors object' do
        result, errors = instance.match object

        expect(result).to be false
        expect(errors).to be errors
      end # it
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

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

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
      let(:errors) { double('errors') }

      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(true)
        allow(instance).to receive(:build_negated_errors).and_return(errors)
      end # before

      it 'should return false and the errors object' do
        result, errors = instance.negated_match object

        expect(result).to be false
        expect(errors).to be errors
      end # it
    end # describe
  end # describe

  describe '#build_errors' do
    it 'should define the method' do
      expect(instance).to respond_to(:build_errors, true).with(1).argument
    end # it

    it 'should return an errors object' do
      errors = instance.send :build_errors, nil

      expect(errors).to be_a Bronze::Errors::Errors
      expect(errors).to satisfy(&:empty?)
    end # it
  end # describe

  describe '#matches_object?' do
    it 'should define the method' do
      expect(instance).to respond_to(:matches_object?, true).with(1).argument
    end # it

    it 'should raise an error' do
      expect { instance.send :matches_object?, nil }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :matches_object?"
    end # it
  end # describe
end # describe
