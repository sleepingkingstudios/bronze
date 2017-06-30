# spec/bronze/entities/operations/insert_one_without_validation_opera..._spec.rb

require 'bronze/entities/operations/insert_one_without_validation_operation'
require 'bronze/entities/operations/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::InsertOneWithoutValidationOperation do # rubocop:disable Metrics/LineLength
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

  include_examples 'should insert the entity into the collection'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should insert the entity into the collection'
  end # wrap_context
end # describe
