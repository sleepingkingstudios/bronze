# spec/bronze/entities/associations/metadata/has_one_metadata_spec.rb

require 'bronze/entities/associations/metadata/association_metadata_examples'
require 'bronze/entities/associations/metadata/has_one_metadata'
require 'bronze/entities/associations/metadata/references_one_metadata'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Associations::Metadata::HasOneMetadata do
  include Spec::Entities::Associations::MetadataExamples

  mock_class Spec, :Dragon, :base_class => Bronze::Entities::Entity

  let(:association_name)  { :dragon }
  let(:association_class) { Spec::Dragon }
  let(:inverse_name)      { :lair }
  let(:association_options) do
    {
      :class_name => association_class.name,
      :inverse    => inverse_name
    } # end hash
  end # let
  let(:inverse_metadata) do
    metadata_class =
      Bronze::Entities::Associations::Metadata::ReferencesOneMetadata
    metadata_class.new inverse_name,
      :class_name  => 'Spec::Lair',
      :foreign_key => :lair_id
  end # let
  let(:instance) do
    described_class.new(association_name, association_options)
  end # let

  before(:example) do
    allow(Spec::Dragon).
      to receive(:associations).
      and_return(inverse_name => inverse_metadata)
  end # before example

  describe '::ASSOCIATION_TYPE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:ASSOCIATION_TYPE).
        with_value(:has_one)
    end # it
  end # describe

  describe '::REQUIRED_KEYS' do
    let(:expected) { %i(inverse) }

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

  describe '#inverse?' do
    it { expect(instance.inverse?).to be true }
  end # describe

  describe '#inverse_metadata' do
    it { expect(instance.inverse_metadata).to be inverse_metadata }
  end # describe

  describe '#inverse_name' do
    it { expect(instance.inverse_name).to be association_options[:inverse] }
  end # describe

  describe '#predicate_name' do
    include_examples 'should have reader',
      :predicate_name,
      ->() { be == :"#{association_name}?" }
  end # describe
end # describe
