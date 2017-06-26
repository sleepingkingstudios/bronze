# spec/bronze/operations/operation_chain_spec.rb

require 'bronze/operations/operation_chain'

module Spec
  module Operations
    class PushOperation < Bronze::Operations::Operation
      def initialize value
        @value = value
      end # constructor

      def process ary = []
        ary << @value
      end # method process
    end # class

    class PushWithErrorOperation < PushOperation
      def process ary = []
        @errors.add 'errors.operations.something_went_wrong'

        super
      end # method process
    end # class
  end # module
end # module

RSpec.describe Bronze::Operations::OperationChain do
  let(:first_operation) do
    Spec::Operations::PushOperation.new('first operation')
  end # let
  let(:instance) { described_class.new first_operation }

  shared_context 'when the first operation is failing' do
    let(:first_operation) do
      Spec::Operations::PushWithErrorOperation.new('operation with error')
    end # let
  end # shared_context

  shared_context 'when there is one chained operation' do
    let(:instance) do
      super().then(Spec::Operations::PushOperation.new('second operation'))
    end # let
  end # shared_context

  shared_context 'when there is one chained block' do
    let(:instance) do
      super().then(Spec::Operations::PushOperation.new('interstitial block'))
    end # let
  end # shared_context

  shared_context 'when there is a chain of passing operations' do
    let(:instance) do
      super().
        then(Spec::Operations::PushOperation.new('second operation')).
        then(Spec::Operations::PushOperation.new('third operation')).
        then(Spec::Operations::PushOperation.new('fourth operation'))
    end # let
  end # shared_context

  shared_context 'when there is a chain with a failing operation' do
    let(:instance) do
      super().
        then(Spec::Operations::PushOperation.new('before error')).
        then(
          Spec::Operations::PushWithErrorOperation.new('operation with error')
        ). # end then
        then(Spec::Operations::PushOperation.new('after error'))
    end # let
  end # shared_context

  shared_context 'when there is a chain with a handled failure' do
    let(:instance) do
      super().
        then(Spec::Operations::PushOperation.new('before error')).
        then(
          Spec::Operations::PushWithErrorOperation.new('operation with error')
        ). # end then
        then(Spec::Operations::PushOperation.new('after error')).
        else(Spec::Operations::PushOperation.new('handle error')).
        then(Spec::Operations::PushOperation.new('after error handler'))
    end # let
  end # shared_context

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    it { expect(instance.call).to be true }

    wrap_context 'when the first operation is failing' do
      it { expect(instance.call).to be false }
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      it { expect(instance.call).to be true }
    end # wrap_context

    wrap_context 'when there is one chained block' do
      it { expect(instance.call).to be true }
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      it { expect(instance.call).to be true }
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      it { expect(instance.call).to be false }
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      it { expect(instance.call).to be true }
    end # wrap_context
  end # describe

  describe '#called?' do
    it { expect(instance.called?).to be false }

    it { expect(instance.execute.called?).to be true }

    wrap_context 'when the first operation is failing' do
      it { expect(instance.called?).to be false }

      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      it { expect(instance.called?).to be false }

      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when there is one chained block' do
      it { expect(instance.called?).to be false }

      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      it { expect(instance.called?).to be false }

      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      it { expect(instance.called?).to be false }

      it { expect(instance.execute.called?).to be true }
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      it { expect(instance.called?).to be false }

      it { expect(instance.execute.called?).to be true }
    end # wrap_context
  end # describe

  describe '#else' do
    let(:expected)       { ['first operation'] }
    let(:expected_error) { 'errors.operations.something_went_wrong' }

    it 'should define the method' do
      expect(instance).to respond_to(:else).with(0..1).arguments.and_a_block
    end # it

    describe 'with a passing operation instance' do
      let(:operation) do
        Spec::Operations::PushOperation.new('else operation')
      end # let

      it { expect(instance.else(operation)).to be instance }

      it 'should chain the operation' do
        chained = instance.else(operation)

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a failing operation instance' do
      let(:operation) do
        Spec::Operations::PushWithErrorOperation.new('failing else operation')
      end # let

      it { expect(instance.else(operation)).to be instance }

      it 'should chain the operation' do
        chained = instance.else(operation)

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a block' do
      it 'should return the chain' do
        chained = instance.else { |op| op.result << 'chained block' }

        expect(chained).to be instance
      end # it

      it 'should chain the block' do
        chained = instance.else { |op| op.result << 'chained block' }

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a block that returns a passing operation' do
      let(:operation) do
        Spec::Operations::PushOperation.new('operation in block')
      end # let

      it 'should return the chain' do
        chained = instance.else { |op| operation.execute(op.result) }

        expect(chained).to be instance
      end # it

      it 'should chain the block' do
        chained = instance.else { |op| operation.execute(op.result) }

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a block that returns a failing operation' do
      let(:operation) do
        Spec::Operations::PushWithErrorOperation.new('failure in block')
      end # let

      it 'should return the chain' do
        chained = instance.else { |op| operation.execute(op.result) }

        expect(chained).to be instance
      end # it

      it 'should chain the block' do
        chained = instance.else { |op| operation.execute(op.result) }

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    wrap_context 'when the first operation is failing' do
      let(:expected) { ['operation with error'] }

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('else operation')
        end # let
        let(:expected) { super() << 'else operation' }

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing else operation')
        end # let
        let(:expected) { super() << 'failing else operation' }

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a block' do
        let(:expected) { super() << 'chained block' }

        it 'should return the chain' do
          chained = instance.else { |op| op.result << 'chained block' }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.else { |op| op.result << 'chained block' }

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a block that returns a passing operation' do
        let(:operation) do
          Spec::Operations::PushOperation.new('operation in block')
        end # let
        let(:expected) { super() << 'operation in block' }

        it 'should return the chain' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a block that returns a failing operation' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failure in block')
        end # let
        let(:expected) { super() << 'failure in block' }

        it 'should return the chain' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      let(:expected) { super() << 'second operation' }

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is one chained block' do
      let(:expected) { super() << 'interstitial block' }

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a block' do
        it 'should return the chain' do
          chained = instance.else { |op| op.result << 'chained block' }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.else { |op| op.result << 'chained block' }

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a block that returns a passing operation' do
        let(:operation) do
          Spec::Operations::PushOperation.new('operation in block')
        end # let

        it 'should return the chain' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a block that returns a failing operation' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failure in block')
        end # let

        it 'should return the chain' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.else { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      let(:expected) do
        super() << 'second operation' << 'third operation' << 'fourth operation'
      end # let

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      let(:expected) do
        super() << 'before error' << 'operation with error'
      end # let

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('else operation')
        end # let
        let(:expected) { super() << 'else operation' }

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing else operation')
        end # let
        let(:expected) { super() << 'failing else operation' }

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      let(:expected) do
        super().concat(
          [
            'before error',
            'operation with error',
            'handle error',
            'after error handler'
          ] # end array
        ) # end concat
      end # let

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing else operation')
        end # let

        it { expect(instance.else(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.else(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#errors' do
    it { expect(instance.errors).to be_empty }

    it { expect(instance.execute.errors).to be_empty }

    wrap_context 'when the first operation is failing' do
      let(:expected) { 'errors.operations.something_went_wrong' }

      it { expect(instance.errors).to be_empty }

      it { expect(instance.execute.errors).to include expected }
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      it { expect(instance.errors).to be_empty }

      it { expect(instance.execute.errors).to be_empty }
    end # wrap_context

    wrap_context 'when there is one chained block' do
      it { expect(instance.errors).to be_empty }

      it { expect(instance.execute.errors).to be_empty }
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      it { expect(instance.errors).to be_empty }

      it { expect(instance.execute.errors).to be_empty }
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      let(:expected) { 'errors.operations.something_went_wrong' }

      it { expect(instance.errors).to be_empty }

      it { expect(instance.execute.errors).to include expected }
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      it { expect(instance.errors).to be_empty }

      it { expect(instance.execute.errors).to be_empty }
    end # wrap_context
  end # describe

  describe '#execute' do
    let(:expected) { ['first operation'] }

    it { expect(instance.execute).to be instance }

    it 'should execute the operation' do
      instance.execute

      expect(instance.called?).to be true
      expect(instance.result).to be == expected
      expect(instance.errors).to be_empty
      expect(instance.success?).to be true
    end # it
  end # describe

  describe '#failure?' do
    it { expect(instance.failure?).to be false }

    it { expect(instance.execute.failure?).to be false }

    wrap_context 'when the first operation is failing' do
      it { expect(instance.failure?).to be false }

      it { expect(instance.execute.failure?).to be true }
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      it { expect(instance.failure?).to be false }

      it { expect(instance.execute.failure?).to be false }
    end # wrap_context

    wrap_context 'when there is one chained block' do
      it { expect(instance.failure?).to be false }

      it { expect(instance.execute.failure?).to be false }
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      it { expect(instance.failure?).to be false }

      it { expect(instance.execute.failure?).to be false }
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      it { expect(instance.failure?).to be false }

      it { expect(instance.execute.failure?).to be true }
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      it { expect(instance.failure?).to be false }

      it { expect(instance.execute.failure?).to be false }
    end # wrap_context
  end # describe

  describe '#result' do
    let(:expected) { ['first operation'] }

    it { expect(instance.result).to be nil }

    it { expect(instance.execute.result).to be == expected }

    wrap_context 'when the first operation is failing' do
      it { expect(instance.result).to be nil }

      it { expect(instance.execute.result).to be == ['operation with error'] }
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      let(:expected) { super() << 'second operation' }

      it { expect(instance.result).to be nil }

      it { expect(instance.execute.result).to be == expected }
    end # wrap_context

    wrap_context 'when there is one chained block' do
      let(:expected) { super() << 'interstitial block' }

      it { expect(instance.result).to be nil }

      it { expect(instance.execute.result).to be == expected }
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      let(:expected) do
        super() << 'second operation' << 'third operation' << 'fourth operation'
      end # let

      it { expect(instance.result).to be nil }

      it { expect(instance.execute.result).to be == expected }
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      let(:expected) do
        super() << 'before error' << 'operation with error'
      end # let

      it { expect(instance.result).to be nil }

      it { expect(instance.execute.result).to be == expected }
    end # method wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      let(:expected) do
        super().concat(
          [
            'before error',
            'operation with error',
            'handle error',
            'after error handler'
          ] # end array
        ) # end concat
      end # let

      it { expect(instance.result).to be nil }

      it { expect(instance.execute.result).to be == expected }
    end # wrap_context
  end # describe

  describe '#success?' do
    it { expect(instance.success?).to be false }

    it { expect(instance.execute.success?).to be true }

    wrap_context 'when the first operation is failing' do
      it { expect(instance.success?).to be false }

      it { expect(instance.execute.success?).to be false }
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      it { expect(instance.success?).to be false }

      it { expect(instance.execute.success?).to be true }
    end # wrap_context

    wrap_context 'when there is one chained block' do
      it { expect(instance.success?).to be false }

      it { expect(instance.execute.success?).to be true }
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      it { expect(instance.success?).to be false }

      it { expect(instance.execute.success?).to be true }
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      it { expect(instance.success?).to be false }

      it { expect(instance.execute.success?).to be false }
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      it { expect(instance.success?).to be false }

      it { expect(instance.execute.success?).to be true }
    end # wrap_context
  end # describe

  describe '#then' do
    let(:expected)       { ['first operation'] }
    let(:expected_error) { 'errors.operations.something_went_wrong' }

    it 'should define the method' do
      expect(instance).to respond_to(:then).with(0..1).arguments.and_a_block
    end # it

    describe 'with a passing operation instance' do
      let(:operation) do
        Spec::Operations::PushOperation.new('chained operation')
      end # let
      let(:expected) { super() << 'chained operation' }

      it { expect(instance.then(operation)).to be instance }

      it 'should chain the operation' do
        chained = instance.then(operation)

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a failing operation instance' do
      let(:operation) do
        Spec::Operations::PushWithErrorOperation.new('failing operation')
      end # let
      let(:expected) { super() << 'failing operation' }

      it { expect(instance.then(operation)).to be instance }

      it 'should chain the operation' do
        chained = instance.then(operation)

        expect(chained.call).to be false
        expect(chained.result).to be == expected
        expect(chained.errors).to include expected_error
      end # it
    end # describe

    describe 'with a block' do
      let(:expected) { super() << 'chained block' }

      it 'should return the chain' do
        chained = instance.then { |op| op.result << 'chained block' }

        expect(chained).to be instance
      end # it

      it 'should chain the block' do
        chained = instance.then { |op| op.result << 'chained block' }

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a block that returns a passing operation' do
      let(:operation) do
        Spec::Operations::PushOperation.new('operation in block')
      end # let
      let(:expected) { super() << 'operation in block' }

      it 'should return the chain' do
        chained = instance.then { |op| operation.execute(op.result) }

        expect(chained).to be instance
      end # it

      it 'should chain the block' do
        chained = instance.then { |op| operation.execute(op.result) }

        expect(chained.call).to be true
        expect(chained.result).to be == expected
        expect(chained.errors).to be_empty
      end # it
    end # describe

    describe 'with a block that returns a failing operation' do
      let(:operation) do
        Spec::Operations::PushWithErrorOperation.new('failure in block')
      end # let
      let(:expected) { super() << 'failure in block' }

      it 'should return the chain' do
        chained = instance.then { |op| operation.execute(op.result) }

        expect(chained).to be instance
      end # it

      it 'should chain the block' do
        chained = instance.then { |op| operation.execute(op.result) }

        expect(chained.call).to be false
        expect(chained.result).to be == expected
        expect(chained.errors).to include expected_error
      end # it
    end # describe

    wrap_context 'when the first operation is failing' do
      let(:expected) { ['operation with error'] }

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('chained operation')
        end # let

        it { expect(instance.then(operation)).to be instance }

        it 'should not chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing operation')
        end # let

        it { expect(instance.then(operation)).to be instance }

        it 'should not chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a block' do
        it 'should return the chain' do
          chained = instance.then { |op| op.result << 'chained block' }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.then { |op| op.result << 'chained block' }

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a block that returns a passing operation' do
        let(:operation) do
          Spec::Operations::PushOperation.new('operation in block')
        end # let

        it 'should return the chain' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a block that returns a failing operation' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failure in block')
        end # let

        it 'should return the chain' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is one chained operation' do
      let(:expected) { super() << 'second operation' }

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('chained operation')
        end # let
        let(:expected) { super() << 'chained operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing operation')
        end # let
        let(:expected) { super() << 'failing operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is one chained block' do
      let(:expected) { super() << 'interstitial block' }

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('chained operation')
        end # let
        let(:expected) { super() << 'chained operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing operation')
        end # let
        let(:expected) { super() << 'failing operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a block' do
        let(:expected) { super() << 'chained block' }

        it 'should return the chain' do
          chained = instance.then { |op| op.result << 'chained block' }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.then { |op| op.result << 'chained block' }

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a block that returns a passing operation' do
        let(:operation) do
          Spec::Operations::PushOperation.new('operation in block')
        end # let
        let(:expected) { super() << 'operation in block' }

        it 'should return the chain' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a block that returns a failing operation' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failure in block')
        end # let
        let(:expected) { super() << 'failure in block' }

        it 'should return the chain' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained).to be instance
        end # it

        it 'should chain the block' do
          chained = instance.then { |op| operation.execute(op.result) }

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is a chain of passing operations' do
      let(:expected) do
        super() << 'second operation' << 'third operation' << 'fourth operation'
      end # let

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('chained operation')
        end # let
        let(:expected) { super() << 'chained operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing operation')
        end # let
        let(:expected) { super() << 'failing operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is a chain with a failing operation' do
      let(:expected) do
        super() << 'before error' << 'operation with error'
      end # let

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('chained operation')
        end # let

        it { expect(instance.then(operation)).to be instance }

        it 'should not chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing operation')
        end # let

        it { expect(instance.then(operation)).to be instance }

        it 'should not chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when there is a chain with a handled failure' do
      let(:expected) do
        super().concat(
          [
            'before error',
            'operation with error',
            'handle error',
            'after error handler'
          ] # end array
        ) # end concat
      end # let

      describe 'with a passing operation instance' do
        let(:operation) do
          Spec::Operations::PushOperation.new('chained operation')
        end # let
        let(:expected) { super() << 'chained operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be true
          expect(chained.result).to be == expected
          expect(chained.errors).to be_empty
        end # it
      end # describe

      describe 'with a failing operation instance' do
        let(:operation) do
          Spec::Operations::PushWithErrorOperation.new('failing operation')
        end # let
        let(:expected) { super() << 'failing operation' }

        it { expect(instance.then(operation)).to be instance }

        it 'should chain the operation' do
          chained = instance.then(operation)

          expect(chained.call).to be false
          expect(chained.result).to be == expected
          expect(chained.errors).to include expected_error
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
