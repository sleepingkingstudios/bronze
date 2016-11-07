# spec/bronze/constraints/constraint_builder.rb

require 'bronze/constraints/constraint_builder'
require 'bronze/constraints/constraint_builder_examples'

RSpec.describe Bronze::Constraints::ConstraintBuilder do
  include Spec::Constraints::ConstraintBuilderExamples

  let(:instance) { Object.new.extend(described_class) }

  include_examples 'should implement the ConstraintBuilder methods'
end # describe
