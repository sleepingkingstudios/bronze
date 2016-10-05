# spec/bronze/constraints/constraint_spec.rb

require 'bronze/constraints/constraint'
require 'bronze/errors/errors'

RSpec.describe Bronze::Constraints::Constraint do
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

      it 'should raise an error' do
        result, errors = instance.match object

        expect(result).to be false
        expect(errors).to be errors
      end # it
    end # describe

    describe 'with an object that matches the constraint' do
      before(:example) do
        allow(instance).to receive(:matches_object?).and_return(true)
      end # before

      it 'should return true and an empty errors object' do
        result, errors = instance.match object

        expect(result).to be true
        expect(errors).to satisfy(&:empty?)
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
