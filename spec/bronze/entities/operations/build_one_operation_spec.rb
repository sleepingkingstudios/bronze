# spec/bronze/entities/operations/build_one_operation_spec.rb

require 'bronze/entities/entity'
require 'bronze/entities/operations/build_one_operation'
require 'bronze/entities/operations/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::BuildOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  let(:arguments) { [] }
  let(:instance)  { described_class.new(entity_class, *arguments) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should build the entity'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should build the entity'
  end # wrap_context
end # describe
