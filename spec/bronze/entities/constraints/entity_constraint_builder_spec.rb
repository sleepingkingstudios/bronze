# spec/bronze/entities/constraints/entity_constraint_builder_spec.rb

require 'bronze/constraints/constraint_builder_examples'
require 'bronze/entities/constraints/entity_constraint_builder'

RSpec.describe Bronze::Entities::Constraints::EntityConstraintBuilder do
  include Spec::Constraints::ConstraintBuilderExamples

  let(:instance) { Object.new.extend(described_class) }

  include_examples 'should implement the ConstraintBuilder methods'

  describe '#build_attribute_types_constraint' do
    let(:method_name)   { :build_attribute_types_constraint }
    let(:method_params) { {} }

    it 'should define the method' do
      expect(instance).
        to respond_to(:build_attribute_types_constraint).
        with(1).argument
    end # it

    include_examples 'should build a constraint',
      Bronze::Entities::Constraints::AttributeTypesConstraint
  end # describe
end # describe
