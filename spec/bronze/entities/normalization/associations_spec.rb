# spec/bronze/entities/normalization/associations_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/normalization'
require 'bronze/entities/normalization/associations'
require 'bronze/entities/normalization/associations_examples'
require 'bronze/entities/primary_key'
require 'bronze/entities/primary_keys/uuid'
require 'support/examples/entities/attributes_examples'
require 'support/examples/entities/normalization_examples'

RSpec.describe Bronze::Entities::Normalization::Associations do
  include Spec::Entities::Normalization::AssociationsExamples
  include Spec::Support::Examples::Entities::AttributesExamples
  include Spec::Support::Examples::Entities::NormalizationExamples

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:instance)           { entity }
  let(:described_class)    { Spec::Book }
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }
  let(:default_attributes) { {} }
  let(:expected_attributes) do
    default_attributes
      .merge(initial_attributes)
      .merge(id: an_instance_of(String))
  end

  example_class 'Spec::Book', Bronze::Entities::BaseEntity do |klass|
    klass.send :include, Bronze::Entities::Associations
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::Normalization
    klass.send :include, Bronze::Entities::Normalization::Associations
    klass.send :include, Bronze::Entities::PrimaryKey
    klass.send :include, Bronze::Entities::PrimaryKeys::Uuid

    klass.define_primary_key :id
  end

  include_examples 'should implement the Normalization methods'

  include_examples 'should implement the Normalization::Associations methods'
end # describe
