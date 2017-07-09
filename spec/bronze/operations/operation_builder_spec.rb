# spec/bronze/operations/operation_builder_spec.rb

require 'bronze/operations/operation_builder'
require 'bronze/operations/operation_builder_examples'

RSpec.describe Bronze::Operations::OperationBuilder do
  include Spec::Operations::OperationBuilderExamples

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

      include_examples 'should execute the operation',
        :receiver => :module_instance
    end # describe
  end # describe

  include_examples 'should implement the OperationBuilder methods'
end # describe
