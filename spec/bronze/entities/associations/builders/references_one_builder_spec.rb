# spec/bronze/entities/associations/builders/references_one_builder_spec.rb

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/associations/builders/references_one_builder'
require 'support/example_entity'

RSpec.describe Bronze::Entities::Associations::Builders::ReferencesOneBuilder do
  include Spec::Entities::Associations::AssociationsExamples

  example_class 'Spec::Author', :base_class => Spec::ExampleEntity
  example_class 'Spec::Book',   :base_class => Spec::ExampleEntity

  let(:entity_class) { Spec::Book }
  let(:instance)     { described_class.new(entity_class) }

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
      expect(metadata.entity_class).to be == entity_class
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
      let(:initial_attributes) { {} }
      let(:entity)             { entity_class.new initial_attributes }
      let(:association_opts) do
        super().merge :class_name => association_class.name
      end # let

      before(:example) do
        associations = { association_name => metadata }

        entity_class.instance_variable_set(:@associations, associations)
      end # before example

      include_examples 'should define references_one association', :author

      describe 'with :inverse => one association' do
        let(:association_opts) { super().merge :inverse => :book }

        before(:example) do
          Spec::Author.has_one(
            :book,
            :class_name => 'Spec::Book',
            :inverse => :author
          ) # end has_one
        end # before example

        include_examples 'should define references_one association',
          :author,
          :inverse => :book
      end # describe
    end # wrap_context
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe
end # describe
