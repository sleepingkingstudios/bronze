# spec/bronze/operations/operation_builder_examples.rb

require 'bronze/operations/operation'

module Spec::Operations
  module OperationBuilderExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the builder is extended in a class' do
      let(:described_class) do
        Class.new.tap { |klass| klass.send :extend, module_instance }
      end # let
    end # shared_context

    shared_examples 'should define the operation method' do |receiver:|
      it 'should define the operation method' do
        expect(send(receiver)).to respond_to(operation_name)
      end # it
    end # shared_examples

    shared_examples 'should execute the operation' do |receiver:|
      let(:operation) do
        defined?(super()) ? super() : operation_class.new
      end # let
      let(:arguments) { [:foo, :bar => :baz] }

      it 'should execute the operation' do
        expect(operation_class).to receive(:new).and_return(operation)

        expect(operation).
          to receive(:process).
          with(*arguments) do |*_args, &block|
            block.call if block
          end # receive

        yielded = false
        result  =
          send(receiver).send(operation_name, *arguments) { yielded = true }

        expect(result).to be operation
        expect(yielded).to be true

        expect(operation).to be_a operation_class
        expect(operation.called?).to be true
      end # it
    end # shared_examples

    shared_examples 'should implement the OperationBuilder methods' do
      describe '#operation' do
        let(:operation_name) { :custom }
        let(:operation_class) do
          klass = defined?(super()) ? super() : Bronze::Operations::Operation

          allow(klass).to receive(:name).and_return('CustomOperation')

          klass
        end # let

        it 'should define the method' do
          expect(module_instance).
            to respond_to(:operation).
            with(1..2).arguments.
            and_a_block
        end # it

        describe 'with an operation class' do
          before(:example) { module_instance.operation(operation_class) }

          include_examples 'should define the operation method',
            :receiver => :module_instance

          include_examples 'should execute the operation',
            :receiver => :module_instance
        end # describe

        describe 'with an operation name and class' do
          let(:operation_name) { :named }

          before(:example) do
            module_instance.operation(operation_name, operation_class)
          end # before example

          include_examples 'should define the operation method',
            :receiver => :module_instance

          include_examples 'should execute the operation',
            :receiver => :module_instance
        end # describe

        describe 'with an operation name and block' do
          before(:example) do
            klass = operation_class

            module_instance.operation(operation_name) { klass.new }
          end # before example

          include_examples 'should define the operation method',
            :receiver => :module_instance

          include_examples 'should execute the operation',
            :receiver => :module_instance
        end # describe

        wrap_context 'when the builder is extended in a class' do
          describe 'with an operation class' do
            before(:example) { module_instance.operation(operation_class) }

            include_examples 'should define the operation method',
              :receiver => :described_class

            include_examples 'should execute the operation',
              :receiver => :described_class
          end # describe

          describe 'with an operation name and class' do
            let(:operation_name) { :named }

            before(:example) do
              module_instance.operation(operation_name, operation_class)
            end # before example
            let(:operation_name) { :named }

            before(:example) do
              module_instance.operation(operation_name, operation_class)
            end # before example

            include_examples 'should define the operation method',
              :receiver => :described_class

            include_examples 'should execute the operation',
              :receiver => :described_class
          end # describe

          describe 'with an operation name and block' do
            before(:example) do
              klass = operation_class

              module_instance.operation(operation_name) { klass.new }
            end # before example

            include_examples 'should define the operation method',
              :receiver => :described_class

            include_examples 'should execute the operation',
              :receiver => :described_class
          end # describe
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
