# spec/bronze/entities/associations/builders/association_builder_spec.rb

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/associations/builders/association_builder'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Associations::Builders::AssociationBuilder do
  include Spec::Entities::Associations::AssociationsExamples

  mock_class Spec, :Author, :base_class => Bronze::Entities::Entity

  let(:entity_class) do
    Class.new(Bronze::Entities::Entity) do
      def initialize attrs = {}
        @associations = {}

        super attrs
      end # method initialize
    end # class
  end # let
  let(:instance) { described_class.new(entity_class) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe
end # describe
