# spec/bronze/entities/associations/metadata/references_one_metadata_spec.rb

require 'bronze/entities/associations/metadata/association_metadata_examples'
require 'bronze/entities/associations/metadata/references_one_metadata'
require 'bronze/entities/entity'

# rubocop:disable Metrics/LineLength
RSpec.describe Bronze::Entities::Associations::Metadata::ReferencesOneMetadata do
  # rubocop:enable Metrics/LineLength
  include Spec::Entities::Associations::MetadataExamples

  mock_class Spec, :Author, :base_class => Bronze::Entities::Entity

  let(:association_name)  { :author }
  let(:association_class) { Spec::Author }
  let(:association_options) do
    {
      :class_name  => association_class.name,
      :foreign_key => :author_id
    } # end hash
  end # let
  let(:instance) do
    described_class.new(association_name, association_options)
  end # let

  describe '::ASSOCIATION_TYPE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:ASSOCIATION_TYPE).
        with_value(:references_one)
    end # it
  end # describe

  describe '::REQUIRED_KEYS' do
    let(:expected) { %i(foreign_key) }

    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:REQUIRED_KEYS).
        with_value(expected)
    end # it
  end # describe

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }

    describe 'should validate the options' do
      describe 'with an invalid option' do
        let(:association_options) { super().merge :invalid_option => true }

        it 'should raise an error' do
          expect do
            described_class.new(
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

      base_class::REQUIRED_KEYS + described_class::REQUIRED_KEYS
    end # let

    it { expect(described_class.required_keys).to contain_exactly(*expected) }
  end # describe

  include_examples 'should implement the AssociationMetadata methods'

  describe '#association_type' do
    let(:expected) { described_class::ASSOCIATION_TYPE }

    it { expect(instance.association_type).to be == expected }
  end # describe

  describe '#foreign_key' do
    it 'should return the option value' do
      expect(instance.foreign_key).
        to be == association_options.fetch(:foreign_key)
    end # it
  end # describe

  describe '#foreign_key?' do
    it { expect(instance.foreign_key?).to be true }
  end # describe

  describe '#foreign_key_reader_name' do
    it 'should return the option value' do
      expect(instance.foreign_key_reader_name).
        to be == association_options.fetch(:foreign_key)
    end # it
  end # describe

  describe '#foreign_key_writer_name' do
    let(:expected) do
      :"#{association_options.fetch(:foreign_key)}="
    end # let

    it { expect(instance.foreign_key_writer_name).to be == expected }
  end # describe

  describe '#predicate_name' do
    include_examples 'should have reader',
      :predicate_name,
      ->() { be == :"#{association_name}?" }
  end # describe
end # describe
