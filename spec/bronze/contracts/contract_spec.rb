# spec/bronze/contracts/contract_spec.rb

require 'bronze/contracts/contract'
require 'bronze/contracts/contract_examples'
require 'bronze/entities/entity'

RSpec.describe Bronze::Contracts::Contract do
  include Spec::Contracts::ContractExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Contract methods'
end # describe
