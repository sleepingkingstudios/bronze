# spec/bronze/entities/normalization/associations_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/normalization'
require 'bronze/entities/normalization/associations'
require 'bronze/entities/normalization/associations_examples'
require 'bronze/entities/normalization/normalization_examples'
require 'bronze/entities/primary_key'

RSpec.describe Bronze::Entities::Normalization::Associations do
  include Spec::Entities::Normalization::AssociationsExamples
  include Spec::Entities::Normalization::NormalizationExamples

  let(:described_class) { Spec::Book }
  let(:attributes)      { {} }
  let(:instance)        { described_class.new attributes }

  example_class 'Spec::Book', Bronze::Entities::BaseEntity do |klass|
    klass.send :include, Bronze::Entities::Associations
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::Normalization
    klass.send :include, Bronze::Entities::Normalization::Associations
    klass.send :include, Bronze::Entities::PrimaryKey
  end

  include_examples 'should implement the Normalization methods'

  include_examples 'should implement the Normalization::Associations methods'
end # describe
