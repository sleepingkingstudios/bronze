# spec/bronze/entities/operations/insert_one_operation_spec.rb

require 'bronze/entities/operations/entity_operation_examples'
require 'bronze/entities/operations/insert_one_operation'

RSpec.describe Bronze::Entities::Operations::InsertOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  let(:arguments) { [repository] }
  let(:instance)  { described_class.new(entity_class, *arguments) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should implement the PersistenceOperation methods'

  include_examples 'should validate and insert the entity into the collection'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should validate and insert the entity into the collection'
  end # wrap_context
end # describe
