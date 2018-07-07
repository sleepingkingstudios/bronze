require 'bronze/entities/operations/assign_one_operation'
require 'bronze/entities/operations/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::AssignOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  subject(:instance) { described_class.new(entity_class: entity_class) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class)
    end
  end

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should assign the attributes to the entity'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should assign the attributes to the entity'
  end
end
