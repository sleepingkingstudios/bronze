# spec/bronze/entities/associations/builders/has_many_builder_spec.rb

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/associations/builders/has_many_builder'
require 'support/example_entity'

RSpec.describe Bronze::Entities::Associations::Builders::HasManyBuilder do
  include Spec::Entities::Associations::AssociationsExamples

  mock_class Spec, :Book, :base_class => Spec::ExampleEntity do |klass|
    klass.references_one(
      :author,
      :class_name => 'Spec::Author',
      :inverse    => :books
    ) # end references_one
  end # mock_class

  mock_class Spec, :Author, :base_class => Spec::ExampleEntity

  let(:entity_class) { Spec::Author }
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

    let(:association_name)  { :books }
    let(:association_class) { Spec::Book }
    let(:association_opts)  { { :class_name => association_class.name } }
    let(:metadata_class) do
      Bronze::Entities::Associations::Metadata::HasManyMetadata
    end # let

    it 'should define the method' do
      expect(instance).to respond_to(:build).with(1..2).arguments
    end # it

    it 'should return the metadata' do
      metadata = instance.build association_name, association_opts

      expect(metadata).to be_a metadata_class
      expect(metadata.entity_class).to be == entity_class
      expect(metadata.association_name).to be == association_name
      expect(metadata.association_type).
        to be == metadata_class::ASSOCIATION_TYPE

      expect(metadata.reader_name).to be == association_name
      expect(metadata.writer_name).to be == :"#{association_name}="

      expect(metadata.inverse_name).to be :author
    end # it

    describe 'with :class_name => value' do
      let(:class_name) { 'Publication' }

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

    describe 'with :inverse => value' do
      let(:inverse_name) { :writer }

      before(:example) do
        association_class.references_one(
          :writer,
          :class_name => 'Spec::Author',
          :inverse    => :books
        ) # end references_one
      end # before example

      it 'should return the metadata' do
        metadata =
          instance.build(
            association_name,
            :class_name => 'Spec::Book',
            :inverse    => inverse_name
          ) # end build

        expect(metadata).to be_a metadata_class
        expect(metadata.inverse_name).to be == inverse_name
      end # it
    end # describe

    wrap_context 'when the association has been defined' do
      let(:attributes) { {} }
      let(:entity)     { entity_class.new attributes }
      let(:association_opts) do
        super().merge :class_name => association_class.name
      end # let

      before(:example) do
        associations = { association_name => metadata }

        entity_class.instance_variable_set(:@associations, associations)
      end # before

      include_examples 'should define has_many association', :books
    end # wrap_context
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe
end # describe
