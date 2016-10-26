# spec/bronze/contracts/type_contract_spec.rb

require 'bronze/contracts/contract_builder'
require 'bronze/contracts/type_contract'
require 'bronze/contracts/type_contract_examples'

RSpec.describe Bronze::Contracts::TypeContract do
  include Spec::Contracts::TypeContractExamples

  let(:described_class) do
    klass = Class.new
    klass.send :include, super()
    klass
  end # let

  include_examples 'should implement the TypeContract methods'
end # describe
