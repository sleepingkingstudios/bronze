# spec/bronze/contracts/contract_builder_spec.rb

require 'bronze/contracts/contract_builder'
require 'bronze/contracts/contract_builder_examples'

RSpec.describe Bronze::Contracts::ContractBuilder do
  include Spec::Contracts::ContractBuilderExamples

  let(:described_class) do
    klass = Class.new do
      def initialize
        @constraints = []
      end # constructor

      attr_reader :constraints
    end # class

    klass.send :include, super()

    klass
  end # let
  let(:instance) { described_class.new }

  include_examples 'should implement the ContractBuilder methods'
end # describe
