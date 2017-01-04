# spec/bronze/entities/associations_spec.rb

require 'bronze/entities/associations'
require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/attributes'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Associations do
  include Spec::Entities::Associations::AssociationsExamples

  let(:described_class) do
    klass = Class.new(Bronze::Entities::BaseEntity)
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, super()
    klass
  end # let
  let(:defined_associations) { {} }
  let(:attributes)           { {} }
  let(:instance)             { described_class.new attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Associations methods'
end # describe
