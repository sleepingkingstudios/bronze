require 'cuprum/operation'

require 'bronze/entities/operations/base_operation'
require 'bronze/entities/operations/persistence_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::PersistenceOperation do
  include Spec::Support::Examples::Entities::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  subject(:instance) do
    described_class.new(entity_class: entity_class, **keywords)
  end

  let(:transform) { nil }
  let(:defaults) do
    {
      repository: Patina::Collections::Simple::Repository.new,
      transform:  Bronze::Transforms::IdentityTransform.new
    }
  end
  let(:keywords) { { repository: repository, transform: transform } }
  let(:described_class) do
    Class.new(Bronze::Entities::Operations::BaseOperation) do
      include Bronze::Entities::Operations::PersistenceOperation
    end
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

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should implement the PersistenceOperation methods'
  end
end
