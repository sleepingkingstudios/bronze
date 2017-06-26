# spec/bronze/operations/operation_spec.rb

require 'bronze/errors'
require 'bronze/operations/operation'

RSpec.describe Bronze::Operations::Operation do
  shared_context 'when the operation runs successfully' do
    before(:example) do
      allow(instance).to receive(:process).and_return(result)
    end # before example
  end # shared_context

  shared_context 'when the operation runs and generates errors' do
    let(:expected_errors) do
      [
        { :type => :library_closed },
        { :type => :already_checked_out, :path => [:book] },
        {
          :type   => :borrowing_privileges_revoked,
          :params => { :duration => [7, :days] },
          :path   => [:user]
        } # end error
      ] # end array
    end # let

    before(:example) do
      errors = expected_errors

      allow(instance).to receive(:process) do
        errors.each do |error|
          proxy = instance.instance_variable_get(:@errors)
          path  = error[:path] || []
          proxy = proxy.dig(*path) unless path.empty?

          proxy.add error[:type], error[:params]
        end # each

        result
      end # allow
    end # before example
  end # shared_context

  shared_context 'when the operation runs and sets a failure message' do
    let(:expected_message) { 'We require more vespene gas.' }

    before(:example) do
      message = expected_message

      allow(instance).to receive(:process) do
        instance.send :failure_message=, message

        result
      end # allow
    end # before example
  end # shared_context

  let(:instance) { described_class.new }
  let(:result)   { double('result') }

  def build_operation
    described_class.new.tap do |operation|
      allow(operation).to receive(:process)
    end # tap
  end # method build_operation

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#always' do
    it 'should define the method' do
      expect(instance).to respond_to(:always).with(0..1).arguments.and_a_block
    end # it

    it 'should return an operation chain' do
      expect(instance.always {}).to be_a Bronze::Operations::OperationChain
    end # it

    wrap_context 'when the operation runs and generates errors' do
      describe 'with a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.always(operation) }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.always(operation) }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block' do
        it 'should call the block' do
          yielded = false

          chained = instance.always { |_| yielded = true }

          expect(chained.call).to be false
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be false
          expect(yielded).to be true
        end # it
      end # describe

      describe 'with a block returning a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          chained = instance.always { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block returning a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          chained = instance.always { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      describe 'with a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.always(operation) }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.always(operation) }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block' do
        it 'should call the block' do
          yielded = false

          chained = instance.always { |_| yielded = true }

          expect(chained.call).to be true
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(yielded).to be true
        end # it
      end # describe

      describe 'with a block returning a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          chained = instance.always { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block returning a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          chained = instance.always { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe
    end # wrap_context
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

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors.empty?).to be false

        expect(instance.errors.count).to be == expected_errors.count
        expected_errors.each do |expected_error|
          expect(instance.errors).to include expected_error
        end # each
      end # it
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it 'should return false' do
        expect(instance.call).to be false

        expect(instance.failure_message).to be == expected_message
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return true' do
        expect(instance.call).to be true

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors.empty?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#called?' do
    include_examples 'should have predicate', :called, false

    wrap_context 'when the operation runs and generates errors' do
      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it { expect(instance.execute.called?).to be true }
    end # wrap_context
  end # describe

  describe '#chain' do
    it 'should define the method' do
      expect(instance).to respond_to(:chain).with(0..1).arguments.and_a_block
    end # it

    it 'should return an operation chain' do
      expect(instance.chain {}).to be_a Bronze::Operations::OperationChain
    end # it

    wrap_context 'when the operation runs and generates errors' do
      describe 'with a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.chain(operation) }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.chain(operation) }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block' do
        it 'should call the block' do
          yielded = false

          chained = instance.chain { |_| yielded = true }

          expect(chained.call).to be false
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be false
          expect(yielded).to be true
        end # it
      end # describe

      describe 'with a block returning a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          chained = instance.chain { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block returning a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          chained = instance.chain { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      describe 'with a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.chain(operation) }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.chain(operation) }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block' do
        it 'should call the block' do
          yielded = false

          chained = instance.chain { |_| yielded = true }

          expect(chained.call).to be true
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(yielded).to be true
        end # it
      end # describe

      describe 'with a block returning a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          chained = instance.chain { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block returning a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          chained = instance.chain { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#else' do
    it 'should define the method' do
      expect(instance).to respond_to(:else).with(0..1).arguments.and_a_block
    end # it

    wrap_context 'when the operation runs and generates errors' do
      describe 'with a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.else(operation) }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.else(operation) }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block' do
        it 'should call the block' do
          yielded = false

          chained = instance.else { |_| yielded = true }

          expect(chained.call).to be false
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be false
          expect(yielded).to be true
        end # it
      end # describe

      describe 'with a block returning a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block returning a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      describe 'with an operation instance' do
        let(:operation) { build_operation }
        let(:chained)   { instance.else(operation) }

        it 'should not call the operation' do
          expect(operation).not_to receive(:process)

          expect(chained.call).to be true
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be false
        end # it
      end # describe

      describe 'with a block' do
        it 'should not call the block' do
          yielded = false

          chained = instance.else { |_| yielded = true }

          expect(chained.call).to be true
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(yielded).to be false
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#errors' do
    include_examples 'should have reader', :errors, ->() { be == [] }

    wrap_context 'when the operation runs and generates errors' do
      it 'should return the errors' do
        instance.call

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors.empty?).to be false

        expect(instance.errors.count).to be == expected_errors.count
        expected_errors.each do |expected_error|
          expect(instance.errors).to include expected_error
        end # each
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return an empty array' do
        instance.call

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors.empty?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#execute' do
    it { expect(instance).to respond_to(:execute).with_unlimited_arguments }

    it 'should raise an error' do
      expect { instance.execute }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :process"
    end # it

    wrap_context 'when the operation runs and generates errors' do
      it 'should return false' do
        expect(instance.execute).to be instance

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors.empty?).to be false

        expect(instance.errors.count).to be == expected_errors.count
        expected_errors.each do |expected_error|
          expect(instance.errors).to include expected_error
        end # each
      end # it
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it 'should return true' do
        expect(instance.execute).to be instance

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors.empty?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#failure?' do
    include_examples 'should have predicate', :failure, false

    wrap_context 'when the operation runs and generates errors' do
      it { expect(instance.execute.failure?).to be true }
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it { expect(instance.execute.failure?).to be true }
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it { expect(instance.execute.failure?).to be false }
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

  describe '#halt!' do
    it { expect(instance).to respond_to(:halt!).with(0).arguments }

    it { expect(instance.halt!).to be instance }

    it 'should flag the operation as halted' do
      expect { instance.halt! }.to change(instance, :halted?).to be true
    end # it
  end # describe

  describe '#halted?' do
    include_examples 'should have predicate', :halted?, false
  end # describe

  describe '#result' do
    include_examples 'should have reader', :result, nil

    wrap_context 'when the operation runs and generates errors' do
      it { expect(instance.execute.result).to be result }
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it { expect(instance.execute.result).to be result }
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it { expect(instance.execute.result).to be result }
    end # wrap_context
  end # describe

  describe '#success?' do
    include_examples 'should have predicate', :success, false

    wrap_context 'when the operation runs and generates errors' do
      it { expect(instance.execute.success?).to be false }
    end # wrap_context

    wrap_context 'when the operation runs and sets a failure message' do
      it { expect(instance.execute.success?).to be false }
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      it { expect(instance.execute.success?).to be true }
    end # wrap_context
  end # describe

  describe '#then' do
    it 'should define the method' do
      expect(instance).to respond_to(:then).with(0..1).arguments.and_a_block
    end # it

    it 'should return an operation chain' do
      expect(instance.then {}).to be_a Bronze::Operations::OperationChain
    end # it

    wrap_context 'when the operation runs and generates errors' do
      describe 'with an operation instance' do
        let(:operation) { build_operation }
        let(:chained)   { instance.then(operation) }

        it 'should not call the operation' do
          expect(operation).not_to receive(:process)

          expect(chained.call).to be false
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be false
          expect(operation.called?).to be false
        end # it
      end # describe

      describe 'with a block' do
        it 'should not call the block' do
          yielded = false

          chained = instance.then { |_| yielded = true }

          expect(chained.call).to be false
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be false
          expect(yielded).to be false
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the operation runs successfully' do
      describe 'with a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.then(operation) }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained)        { instance.then(operation) }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block' do
        it 'should call the block' do
          yielded = false

          chained = instance.then { |_| yielded = true }

          expect(chained.call).to be true
          expect(chained.result).to be result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(yielded).to be true
        end # it
      end # describe

      describe 'with a block returning a passing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }

        it 'should call the operation' do
          expect(operation).
            to receive(:process).with(result).and_return(chained_result)

          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors.empty?).to be true
          expect(operation.called?).to be true
        end # it
      end # describe

      describe 'with a block returning a failing operation instance' do
        let(:operation)      { build_operation }
        let(:chained_result) { double('chained result') }
        let(:chained_error)  { 'errors.operations.chained_failure' }

        it 'should call the operation' do
          expect(operation).to receive(:process).with(result) do |param|
            expect(param).to be result

            operation.errors.add(chained_error)

            chained_result
          end # let

          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be chained_result
          expect(chained.errors).to be_a Bronze::Errors
          expect(chained.errors).to include chained_error
          expect(operation.called?).to be true
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
