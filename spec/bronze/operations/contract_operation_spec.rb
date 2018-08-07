require 'cuprum/operation'

require 'bronze/operations/base_operation'
require 'bronze/operations/contract_operation'

require 'support/examples/entity_operation_examples'

RSpec.describe Bronze::Operations::ContractOperation do
  include Spec::Support::Examples::EntityOperationExamples

  include_context 'when the entity class is defined'

  subject(:instance) do
    described_class.new(entity_class: entity_class, **keywords)
  end

  let(:contract) { nil }
  let(:defaults) { { contract: Bronze::Contracts::Contract.new } }
  let(:keywords) { {} }
  let(:described_class) do
    Class.new(Bronze::Operations::BaseOperation) do
      include Bronze::Operations::ContractOperation
    end
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :contract)
    end
  end

  include_examples 'should implement the ContractOperation methods'

  include_examples 'should implement the EntityOperation methods'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should implement the ContractOperation methods'
  end
end
