# spec/bronze/entities/operations/persistence_operation_spec.rb

require 'bronze/entities/operations/entity_operation_examples'
require 'bronze/entities/operations/persistence_operation'

RSpec.describe Bronze::Entities::Operations::PersistenceOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  let(:arguments) { [repository] }
  let(:instance)  { described_class.new(entity_class, *arguments) }

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should implement the PersistenceOperation methods'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should implement the PersistenceOperation methods'
  end # wrap_context
end # describe
