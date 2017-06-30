# spec/bronze/entities/operations/persistence_operation_spec.rb

require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/entity_operation_examples'
require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

RSpec.describe Bronze::Entities::Operations::PersistenceOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  let(:described_class) do
    Class.new(Bronze::Operations::Operation) do
      include Bronze::Entities::Operations::EntityOperation
      include Bronze::Entities::Operations::PersistenceOperation
    end # class
  end # let

  let(:arguments) { [repository] }
  let(:instance)  { described_class.new(entity_class, *arguments) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should implement the PersistenceOperation methods'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should implement the PersistenceOperation methods'
  end # wrap_context
end # describe
