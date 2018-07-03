require 'bronze/entities/operations/build_one_operation'
require 'bronze/entities/operations/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::BuildOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  let(:instance) do
    described_class.new(entity_class: entity_class)
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class)
    end
  end

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should build the entity'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should build the entity'
  end
end
