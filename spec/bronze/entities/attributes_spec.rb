# spec/bronze/entities/attributes_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/attributes/attributes_examples'

RSpec.describe Bronze::Entities::Attributes do
  include Spec::Entities::Attributes::AttributesExamples

  let(:described_class) do
    Class.new.tap { |klass| klass.send :include, super() }
  end # let
  let(:defined_attributes) { {} }
  let(:attributes)         { {} }
  let(:instance)           { described_class.new attributes }

  include_examples 'should implement the Attributes methods'
end # describe
