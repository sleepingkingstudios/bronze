# spec/bronze/operations/operation_builder_spec.rb

require 'bronze/operations/operation_builder'
require 'bronze/operations/operation_builder_examples'

RSpec.describe Bronze::Operations::OperationBuilder do
  include Bronze::Operations::OperationBuilderExamples

  let(:module_instance) { Bronze::Operations::OperationBuilder.new }
  let(:operation_class) do
    Class.new(Bronze::Operations::Operation) do
      def self.name
        'CustomOperation'
      end # class method name

      def process *_args
        yield if block_given?
      end # method process
    end # class
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }

    describe 'with a block' do
      let(:operation_name) { :custom }
      let(:operation_class) do
        klass = Class.new(Bronze::Operations::Operation)

        allow(klass).to receive(:name).and_return('CustomOperation')

        klass
      end # let
      let(:module_instance) do
        name       = operation_name
        definition = operation_class

        Bronze::Operations::OperationBuilder.new do
          operation name, definition
        end # module
      end # let

      include_examples 'should define the operation method',
        :receiver => :module_instance

      include_examples 'should build the operation',
        :receiver => :module_instance
    end # describe
  end # describe

  include_examples 'should implement the OperationBuilder methods'

  describe '#operation' do
    context 'when the operation class constructor has parameters' do
      shared_examples 'should build the operation with the given args' \
      do |receiver:|
        let(:expected_class) do
          defined?(super()) ? super() : operation_class
        end # let
        let(:value) { double('value') }

        it 'should build the operation' do
          operation = send(receiver).send(operation_name, value)

          expect(operation).to be_a expected_class
          expect(operation.called?).to be false
          expect(operation.value).to be value
        end # it
      end # shared_examples

      let(:operation_name) { :custom }
      let(:operation_class) do
        Class.new(Bronze::Operations::Operation) do
          def self.name
            'CustomOperation'
          end # class method name

          def initialize value
            @value = value
          end # constructor

          attr_reader :value
        end # class
      end # let

      describe 'with an operation class' do
        before(:example) { module_instance.operation(operation_class) }

        include_examples 'should build the operation with the given args',
          :receiver => :module_instance
      end # describe

      describe 'with an operation name and class' do
        let(:operation_name) { :named }

        before(:example) do
          module_instance.operation(operation_name, operation_class)
        end # before example

        include_examples 'should build the operation with the given args',
          :receiver => :module_instance
      end # describe

      describe 'with an operation name and block' do
        before(:example) do
          klass = operation_class

          module_instance.operation(operation_name) { |val| klass.new(val) }
        end # before example

        include_examples 'should build the operation with the given args',
          :receiver => :module_instance
      end # describe

      wrap_context 'when the builder is extended in a class' do
        describe 'with an operation class' do
          before(:example) { module_instance.operation(operation_class) }

          include_examples 'should build the operation with the given args',
            :receiver => :described_class
        end # describe

        describe 'with an operation name and class' do
          let(:operation_name) { :named }

          before(:example) do
            module_instance.operation(operation_name, operation_class)
          end # before example

          include_examples 'should build the operation with the given args',
            :receiver => :described_class
        end # describe

        describe 'with an operation name and block' do
          before(:example) do
            klass = operation_class

            module_instance.operation(operation_name) { |val| klass.new(val) }
          end # before example

          include_examples 'should build the operation with the given args',
            :receiver => :described_class
        end # describe
      end # wrap_context
    end # context
  end # describe
end # describe
