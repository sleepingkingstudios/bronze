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

  include_examples 'should implement the OperationBuilder methods'
end # describe
