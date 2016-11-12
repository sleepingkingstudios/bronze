# spec/bronze/entities/constraints/entity_constraint_builder_spec.rb

require 'bronze/constraints/constraint_builder_examples'
require 'bronze/entities/constraints/entity_constraint_builder'

RSpec.describe Bronze::Entities::Constraints::EntityConstraintBuilder do
  include Spec::Constraints::ConstraintBuilderExamples

  let(:instance) { Object.new.extend(described_class) }

  include_examples 'should implement the ConstraintBuilder methods'

  include_examples 'should implement the EntityConstraintBuilder methods'
end # describe
