# spec/bronze/entities/normalization_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/normalization'
require 'bronze/entities/normalization_examples'

RSpec.describe Bronze::Entities::Normalization do
  include Spec::Entities::NormalizationExamples

  let(:described_class) do
    Class.new(Bronze::Entities::BaseEntity) do
      include Bronze::Entities::Attributes
      include Bronze::Entities::Normalization
    end # described_class
  end # let
  let(:attributes) { {} }
  let(:instance)   { described_class.new attributes }

  include_examples 'should implement the Normalization methods'
end # describe
