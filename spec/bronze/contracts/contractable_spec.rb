# spec/bronze/contracts/contractable_spec.rb

require 'bronze/contracts/contract'
require 'bronze/contracts/contractable'

RSpec.describe Bronze::Contracts::Contractable do
  let(:described_class) do
    klass = Class.new
    klass.send :include, super()
    klass
  end # let

  describe '::contract' do
    it 'should define the method' do
      expect(described_class).
        to respond_to(:contract).
        with(0).arguments.
        and_a_block
    end # it

    it 'should return an empty contract' do
      contract = described_class.contract

      expect(contract).to be_a Bronze::Contracts::Contract
      expect(contract.constraints).to satisfy(&:empty?)
    end # it

    describe 'with a block' do
      it 'should execute the block in the context of the contract' do
        contract  = described_class.contract
        called_by = nil

        described_class.contract do
          called_by = self
        end # contract

        expect(called_by).to be contract
      end # it
    end # describe
  end # describe
end # describe
