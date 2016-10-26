# spec/bronze/entities/contracts/entity_contract_builder_spec.rb

require 'bronze/contracts/contract_builder_examples'
require 'bronze/entities/contracts/entity_contract_builder'

RSpec.describe Bronze::Entities::Contracts::EntityContractBuilder do
  include Spec::Contracts::ContractBuilderExamples

  let(:contract) { nil }
  let(:instance) { described_class.new contract }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '#constrain_attribute_types' do
    it 'should define the method' do
      expect(instance).
        to respond_to(:constrain_attribute_types).
        with(0).arguments
    end # it

    it 'should add a constraint to the contract' do
      constraints = instance.contract.constraints

      expect { instance.constrain_attribute_types }.
        to change(constraints, :count).by(1)

      data = constraints.last
      expect(data.nesting).to be == []
      expect(data.negated?).to be false

      constraint_type = Bronze::Entities::Constraints::AttributeTypesConstraint
      expect(data.constraint).to be_a constraint_type
    end # it
  end # describe

  include_examples 'should implement the ContractBuilder methods'
end # describe
