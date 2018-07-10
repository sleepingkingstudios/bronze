require 'bronze/entities/operations/entity_operation_examples'
require 'bronze/entities/operations/find_many_operation'

RSpec.describe Bronze::Entities::Operations::FindManyOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  subject(:instance) { described_class.new(**keywords) }

  let(:transform) { nil }
  let(:keywords) do
    { entity_class: entity_class, repository: repository, transform: transform }
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :repository, :transform)
    end
  end

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should implement the PersistenceOperation methods'

  include_examples 'should find the entities with given primary keys'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should find the entities with given primary keys'
  end
end
