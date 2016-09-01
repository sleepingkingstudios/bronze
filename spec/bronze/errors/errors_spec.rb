# spec/bronze/errors/errors_spec.rb

require 'bronze/errors/errors'

RSpec.describe Bronze::Errors::Errors do
  shared_context 'when many errors are added' do
    let(:errors) do
      {
        :must_be_present      => [],
        :must_be_numeric      => [],
        :must_be_greater_than => [0]
      } # end hash
    end # let

    before(:example) do
      errors.each do |error_type, error_params|
        instance.add error_type, *error_params
      end # each
    end # before example
  end # shared_context

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#add' do
    it 'should define the method' do
      expect(instance).
        to respond_to(:add).
        with(1).argument.
        and_unlimited_arguments
    end # it

    describe 'with an error type' do
      let(:error_type) { :must_be_present }

      it 'should append an error' do
        expect { instance.add error_type }.
          to change { instance.to_a.count }.
          by 1

        error = instance.to_a.last
        expect(error).to be_a Bronze::Errors::Error
        expect(error.type).to be error_type
        expect(error.params).to be == []
      end # it
    end # describe

    describe 'with an error type and params' do
      let(:error_type)   { :must_be_between }
      let(:error_params) { [0, 1] }

      it 'should append an error' do
        expect { instance.add error_type, *error_params }.
          to change { instance.to_a.count }.
          by 1

        error = instance.to_a.last
        expect(error).to be_a Bronze::Errors::Error
        expect(error.type).to be error_type
        expect(error.params).to be == error_params
      end # it
    end # describe
  end # describe

  describe '#each' do
    it { expect(instance).to respond_to(:each).with(0).arguments.and_a_block }

    wrap_context 'when many errors are added' do
      it 'should yield the errors' do
        ary = []

        instance.each { |error| ary << error }

        expect(ary.map(&:type)).to contain_exactly(*errors.keys)
        ary.each do |error|
          expect(error.params).to be == errors[error.type]
        end # each
      end # it
    end # wrap_context
  end # describe

  describe '#to_a' do
    it { expect(instance).to respond_to(:to_a).with(0).arguments }

    it { expect(instance.to_a).to be == [] }

    wrap_context 'when many errors are added' do
      it 'should return the errors' do
        ary = instance.to_a
        expect(ary.map(&:type)).to contain_exactly(*errors.keys)
        ary.each do |error|
          expect(error.params).to be == errors[error.type]
        end # each
      end # it
    end # wrap_context
  end # describe
end # describe
