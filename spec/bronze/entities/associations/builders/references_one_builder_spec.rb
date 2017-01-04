# spec/bronze/entities/associations/builders/references_one_builder_spec.rb

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/associations/builders/references_one_builder'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Associations::Builders::ReferencesOneBuilder do
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

  describe '#build' do
    shared_context 'when the association has been defined' do
      let!(:metadata) do
        instance.build association_name, association_opts
      end # let!
    end # shared_context

    let(:association_name)  { :author }
    let(:association_class) { Spec::Author }
    let(:association_opts)  { {} }
    let(:metadata_class) do
      Bronze::Entities::Associations::Metadata::ReferencesOneMetadata
    end # let

    it 'should define the method' do
      expect(instance).to respond_to(:build).with(1..2).arguments
    end # it

    it 'should return the metadata' do
      metadata = instance.build association_name

      expect(metadata).to be_a metadata_class
      expect(metadata.association_name).to be == association_name
      expect(metadata.association_type).
        to be == metadata_class::ASSOCIATION_TYPE

      expect(metadata.reader_name).to be == association_name
      expect(metadata.writer_name).to be == :"#{association_name}="

      expect(metadata.foreign_key).to be == :"#{association_name}_id"
    end # it

    describe 'with :class_name => value' do
      let(:class_name) { 'Person' }

      it 'should return the metadata' do
        metadata =
          instance.build(
            association_name,
            :class_name => class_name
          ) # end build

        expect(metadata).to be_a metadata_class
        expect(metadata.class_name).to be == class_name
      end # it
    end # describe

    describe 'with :foreign_key => value' do
      let(:foreign_key) { :person_id }

      it 'should return the metadata' do
        metadata =
          instance.build(
            association_name,
            :foreign_key => foreign_key
          ) # end build

        expect(metadata).to be_a metadata_class
        expect(metadata.foreign_key).to be == foreign_key
      end # it
    end # describe

    wrap_context 'when the association has been defined' do
      let(:attributes) { {} }
      let(:entity)     { entity_class.new }
      let(:association_opts) do
        super().merge :class_name => association_class.name
      end # let

      include_examples 'should define references_one association', :author
    end # wrap_context
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe
end # describe
