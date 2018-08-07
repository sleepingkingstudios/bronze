require 'cuprum/operation'

require 'bronze/operations/entity_operation'

require 'support/example_entity'
require 'support/examples/entity_operation_examples'

RSpec.describe Bronze::Operations::EntityOperation do
  include Spec::Support::Examples::EntityOperationExamples

  subject(:instance) { described_class.new(entity_class: entity_class) }

  let(:described_class) do
    Class.new(Cuprum::Operation) do
      include Bronze::Operations::EntityOperation
    end
  end
  let(:entity_class) { Spec::ExampleEntity }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with_unlimited_arguments
        .and_keywords(:entity_class)
        .and_any_keywords
    end
  end

  include_examples 'should implement the EntityOperation methods'
end
