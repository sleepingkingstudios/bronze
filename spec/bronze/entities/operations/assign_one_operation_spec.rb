# spec/bronze/entities/operations/assign_one_operation_spec.rb

require 'bronze/entities/operations/assign_one_operation'
require 'bronze/entities/operations/entity_operation_examples'

RSpec.xdescribe Bronze::Entities::Operations::AssignOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  let(:arguments) { [] }
  let(:instance)  { described_class.new(entity_class, *arguments) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should assign the attributes to the entity'

  wrap_context 'when a subclass is defined with the entity class' do
    include_examples 'should assign the attributes to the entity'
  end # wrap_context
end # describe
