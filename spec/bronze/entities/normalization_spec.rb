# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/normalization'

require 'support/examples/entities/attributes_examples'
require 'support/examples/entities/normalization_examples'

RSpec.describe Bronze::Entities::Normalization do
  include Support::Examples::Entities::AttributesExamples
  include Support::Examples::Entities::NormalizationExamples

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:described_class)    { Spec::EntityWithNormalization }
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }

  # rubocop:disable RSpec/DescribedClass
  example_class 'Spec::EntityWithNormalization' do |klass|
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::Normalization
  end
  # rubocop:enable RSpec/DescribedClass

  include_examples 'should implement the Normalization methods'
end
