# spec/bronze/contracts/contract_builder_spec.rb

require 'bronze/contracts/contract_builder'
require 'bronze/contracts/contract_builder_examples'

RSpec.describe Bronze::Contracts::ContractBuilder do
  include Spec::Contracts::ContractBuilderExamples

  let(:contract) { nil }
  let(:instance) { described_class.new contract }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the ContractBuilder methods'
end # describe
