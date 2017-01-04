# spec/bronze/entities/attributes_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/attributes/attributes_examples'
require 'bronze/entities/base_entity'

RSpec.describe Bronze::Entities::Attributes do
  include Spec::Entities::Attributes::AttributesExamples

  let(:described_class) do
    klass = Class.new(Bronze::Entities::BaseEntity)
    klass.send :include, super()
    klass
  end # let
  let(:defined_attributes) { {} }
  let(:attributes)         { {} }
  let(:instance)           { described_class.new attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Attributes methods'
end # describe
