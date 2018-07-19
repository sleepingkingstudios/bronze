require 'cuprum/operation'

require 'bronze/entities/operations/contract_operation'
require 'bronze/entities/operations/entity_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::ContractOperation do
  include Spec::Support::Examples::Entities::EntityOperationExamples

  include_context 'when the entity class is defined'

  subject(:instance) { described_class.new(**keywords) }

  let(:contract) { nil }
  let(:keywords) { { entity_class: entity_class } }
  let(:described_class) do
    Class.new(Cuprum::Operation) do
      include Bronze::Entities::Operations::ContractOperation
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
