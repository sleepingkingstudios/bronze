# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/normalization'
require 'bronze/entities/primary_key'

require 'support/examples/entities/attributes_examples'
require 'support/examples/entities/normalization_examples'
require 'support/examples/entities/primary_key_examples'

RSpec.describe Bronze::Entities::Normalization do
  include Support::Examples::Entities::AttributesExamples
  include Support::Examples::Entities::NormalizationExamples
  include Support::Examples::Entities::PrimaryKeyExamples

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:described_class)    { Spec::EntityWithNormalization }
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }
  let(:default_attributes) do
    entity_class.each_attribute.reduce({}) do |hsh, (key, metadata)|
      hsh.merge(key => metadata.default)
    end
  end
  let(:expected_attributes) do
    default_attributes.merge(initial_attributes)
  end

  # rubocop:disable RSpec/DescribedClass
  example_class 'Spec::EntityWithNormalization' do |klass|
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::Normalization
  end
  # rubocop:enable RSpec/DescribedClass

  include_examples 'should implement the Normalization methods'

  wrap_context 'when the entity class has a primary key' do
    let(:described_class) { Spec::EntityWithPrimaryKey }
    let(:expected_attributes) do
      super().merge(id: an_instance_of(Integer))
    end

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::EntityWithPrimaryKey' do |klass|
      klass.send :include, Bronze::Entities::Attributes
      klass.send :include, Bronze::Entities::Normalization
      klass.send :include, Bronze::Entities::PrimaryKey
    end
    # rubocop:enable RSpec/DescribedClass

    include_examples 'should implement the Normalization methods'
  end
end
