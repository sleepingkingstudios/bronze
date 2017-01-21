# spec/bronze/entities/associations/metadata/has_many_metadata_spec.rb

require 'bronze/entities/associations/metadata/association_metadata_examples'
require 'bronze/entities/associations/metadata/has_many_metadata'
require 'bronze/entities/associations/metadata/references_one_metadata'
require 'support/example_entity'

RSpec.describe Bronze::Entities::Associations::Metadata::HasManyMetadata do
  include Spec::Entities::Associations::MetadataExamples

  shared_examples 'should validate the inverse metadata' do
    wrap_examples 'should validate the inverse metadata inverse'

    wrap_examples 'should validate the inverse metadata type'

    wrap_context 'when options[:inverse] is nil' do
      include_examples 'should validate the inverse metadata presence'
    end # wrap_context

    wrap_context 'when options[:inverse] is unset' do
      include_examples 'should validate the inverse metadata presence'
    end # wrap_context

    wrap_context 'when the inverse relation is undefined' do
      include_examples 'should validate the inverse metadata presence'
    end # wrap_context
  end # shared_examples

  mock_class Spec, :Author, :base_class => Spec::ExampleEntity
  mock_class Spec, :Book,   :base_class => Spec::ExampleEntity

  let(:association_name)  { :books }
  let(:association_class) { Spec::Book }
  let(:inverse_name)      { :author }
  let(:association_options) do
    {
      :class_name => association_class.name,
      :inverse    => inverse_name
    } # end hash
  end # let
  let(:inverse_metadata) do
    build_valid_inverse_metadata(inverse_name)
  end # let
  let(:entity_class) { Spec::Author }
  let(:instance) do
    described_class.new(entity_class, association_name, association_options)
  end # let

  def build_invalid_inverse_metadata inverse_name
    Bronze::Entities::Associations::Metadata::HasOneMetadata.new(
      association_class,
      inverse_name,
      :class_name => 'Spec::Author'
    ) # end new
  end # method build_valid_inverse_metadata

  def build_valid_inverse_metadata inverse_name
    Bronze::Entities::Associations::Metadata::ReferencesOneMetadata.new(
      association_class,
      inverse_name,
      :class_name  => 'Spec::Author',
      :foreign_key => :author_id
    ) # end new
  end # method build_valid_inverse_metadata

  before(:example) do
    allow(Spec::Book).
      to receive(:associations).
      and_return(inverse_name => inverse_metadata)
  end # before example

  describe '::ASSOCIATION_TYPE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:ASSOCIATION_TYPE).
        with_value(:has_many)
    end # it
  end # describe

  describe '::new' do
    it { expect(described_class).to be_constructible.with(3).arguments }

    describe 'should validate the options' do
      describe 'with an invalid option' do
        let(:association_options) { super().merge :invalid_option => true }

        it 'should raise an error' do
          expect do
            described_class.new(
              entity_class,
              association_name,
              association_options
            ) # end new
          end.to raise_error ArgumentError, 'invalid option :invalid_option'
        end # it
      end # describe

      describe 'with a missing option' do
        before(:example) do
          keys = described_class.required_keys

          allow(described_class).
            to receive(:required_keys).
            and_return(keys + %i(required_option))
        end # before example

        it 'should raise an error' do
          expect do
            described_class.new(
              entity_class,
              association_name,
              association_options
            ) # end new
          end.to raise_error ArgumentError, 'missing option :required_option'
        end # it
      end # describe
    end # describe
  end # describe

  describe '::optional_keys' do
    let(:expected) do
      base_class = Bronze::Entities::Associations::Metadata::AssociationMetadata

      base_class::OPTIONAL_KEYS
    end # let

    it { expect(described_class.optional_keys).to contain_exactly(*expected) }
  end # describe

  describe '::required_keys' do
    let(:expected) do
      base_class = Bronze::Entities::Associations::Metadata::AssociationMetadata

      base_class::REQUIRED_KEYS
    end # let

    it { expect(described_class.required_keys).to contain_exactly(*expected) }
  end # describe

  include_examples 'should implement the AssociationMetadata methods'

  describe '#association_type' do
    let(:expected) { described_class::ASSOCIATION_TYPE }

    it { expect(instance.association_type).to be == expected }
  end # describe

  describe '#inverse?' do
    def call_method
      instance.inverse?
    end # method call_method

    it { expect(instance.inverse?).to be true }

    include_examples 'should validate the inverse metadata'
  end # describe

  describe '#inverse_metadata' do
    def call_method
      instance.inverse_metadata
    end # method call_method

    it { expect(instance.inverse_metadata).to be inverse_metadata }

    include_examples 'should validate the inverse metadata'
  end # describe

  describe '#inverse_name' do
    def call_method
      instance.inverse_name
    end # method call_method

    it { expect(instance.inverse_name).to be association_options[:inverse] }

    include_examples 'should validate the inverse metadata'
  end # describe

  describe '#many?' do
    it { expect(instance.many?).to be true }
  end # describe

  describe '#one?' do
    it { expect(instance.one?).to be false }
  end # describe
end # describe
