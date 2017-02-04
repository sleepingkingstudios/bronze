# spec/bronze/operations/operation_spec.rb

require 'bronze/errors/error'
require 'bronze/errors/errors'
require 'bronze/operations/operation'

RSpec.describe Bronze::Operations::Operation do
  shared_context 'when the operation runs successfully' do
    before(:example) do
      allow(instance).to receive(:process)
    end # before example
  end # shared_context

  shared_context 'when the operation runs and generates errors' do
    let(:expected_errors) do
      [
        Bronze::Errors::Error.new([], :library_closed, {}),
        Bronze::Errors::Error.new([:book], :already_checked_out, {}),
        Bronze::Errors::Error.new(
          [:user], :borrowing_privileges_revoked, :duration => [7, :days]
        ) # end error
      ] # end array
    end # let

    before(:example) do
      errors = expected_errors

      allow(instance).to receive(:process) do
        errors.each do |error|
          nesting = instance.instance_variable_get(:@errors)

          error.nesting.each { |fragment| nesting = nesting[fragment] }

          nesting.add(error.type, **error.params)
        end # each
      end # allow
    end # before example
  end # shared_context

  shared_context 'when the operation runs and sets a failure message' do
    let(:expected_message) { 'We require more vespene gas.' }
    before(:example) do
      message = expected_message

      allow(instance).to receive(:process) do
        instance.send :failure_message=, message
      end # allow
    end # before example
  end # shared_context

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#call' do
    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    it { expect(instance).to alias_method(:call).as(:run) }

    it 'should raise an error' do
      expect { instance.call }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :process"
    end # it

    wrap_context 'when the operation runs and generates errors' do
      it 'should return false' do
        expect(instance.call).to be false

        expect(instance.errors).to be_a Bronze::Errors::Errors
        expect(instance.errors.empty?).to be false

        expect(instance.errors.to_a).to contain_exactly(*expected_errors)
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return true' do
        expect(instance.call).to be true

        expect(instance.errors).to be_a Bronze::Errors::Errors
        expect(instance.errors.empty?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#errors' do
    include_examples 'should have reader', :errors, ->() { be == [] }

    wrap_context 'when the operation runs and generates errors' do
      it 'should return the errors' do
        instance.call

        expect(instance.errors).to be_a Bronze::Errors::Errors
        expect(instance.errors.empty?).to be false

        expect(instance.errors.to_a).to contain_exactly(*expected_errors)
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return an empty array' do
        instance.call

        expect(instance.errors).to be_a Bronze::Errors::Errors
        expect(instance.errors.empty?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#failure?' do
    include_examples 'should have predicate', :failure, false

    wrap_context 'when the operation runs and generates errors' do
      it 'should return true' do
        instance.call

        expect(instance.failure?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it 'should return true' do
        instance.call

        expect(instance.failure?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return false' do
        instance.call

        expect(instance.failure?).to be false
      end # it
    end # wrap_context
  end # describe

  describe '#failure_message' do
    include_examples 'should have reader', :failure_message, nil

    wrap_context 'when the operation runs and sets a failure message' do
      it 'should return the failure message' do
        instance.call

        expect(instance.failure_message).to be == expected_message
      end # it
    end # wrap_context
  end # describe

  describe '#success?' do
    include_examples 'should have predicate', :success, false

    wrap_context 'when the operation runs and generates errors' do
      it 'should return false' do
        instance.call

        expect(instance.success?).to be false
      end # it
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it 'should return false' do
        instance.call

        expect(instance.success?).to be false
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return true' do
        instance.call

        expect(instance.success?).to be true
      end # it
    end # wrap_context
  end # describe
end # describe
