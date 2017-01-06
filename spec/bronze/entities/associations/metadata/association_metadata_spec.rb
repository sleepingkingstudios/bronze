# spec/bronze/entities/associations/metadata/association_metadata_spec.rb

require 'bronze/entities/associations/metadata/association_metadata'
require 'bronze/entities/associations/metadata/association_metadata_examples'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Associations::Metadata::AssociationMetadata do
  include Spec::Entities::Associations::MetadataExamples

  shared_context 'when options[:inverse] is set' do
    let(:inverse_name)    { :books }
    let(:inverse_options) { { :class_name => 'Spec::Book' } }
    let(:inverse_metadata) do
      described_class.new association_type, inverse_name, inverse_options
    end # let
    let(:association_options) do
      super().merge :inverse => inverse_name
    end # let

    before(:example) do
      allow(Spec::Author).
        to receive(:associations).
        and_return(inverse_name => inverse_metadata)
    end # before example
  end # shared_context

  mock_class Spec, :Author, :base_class => Bronze::Entities::Entity

  let(:association_type)    { :example_association }
  let(:association_name)    { :author }
  let(:association_class)   { Spec::Author }
  let(:association_options) { { :class_name => association_class.name } }
  let(:instance) do
    described_class.new(association_type, association_name, association_options)
  end # let

  describe '::OPTIONAL_KEYS' do
    let(:expected) do
      %i(inverse)
    end # let

    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:OPTIONAL_KEYS).
        with_value(expected)
    end # it
  end # describe

  describe '::REQUIRED_KEYS' do
    let(:expected) do
      %i(class_name)
    end # let

    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:REQUIRED_KEYS).
        with_value(expected)
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
              association_type,
              association_name,
              association_options
            ) # end new
          end.to raise_error ArgumentError, 'invalid option :invalid_option'
        end # it
      end # describe
    end # describe
  end # describe

  describe '::optional_keys' do
    let(:expected) { described_class::OPTIONAL_KEYS }

    it { expect(described_class.optional_keys).to be == expected }
  end # describe

  describe '::required_keys' do
    let(:expected) { described_class::REQUIRED_KEYS }

    it { expect(described_class.required_keys).to be == expected }
  end # describe

  include_examples 'should implement the AssociationMetadata methods'

  describe '#association_type' do
    it { expect(instance.association_type).to be == association_type }
  end # describe

  describe '#class_name' do
    it { expect(instance.class_name).to be == association_options[:class_name] }
  end # describe

  describe '#foreign_key' do
    it { expect(instance.foreign_key).to be nil }
  end # describe

  describe '#foreign_key?' do
    it { expect(instance.foreign_key?).to be false }
  end # describe

  describe '#foreign_key_reader_name' do
    it { expect(instance.foreign_key_reader_name).to be nil }
  end # describe

  describe '#foreign_key_writer_name' do
    it { expect(instance.foreign_key_writer_name).to be nil }
  end # describe

  describe '#inverse' do
    it { expect(instance.inverse?).to be false }

    wrap_context 'when options[:inverse] is set' do
      it { expect(instance.inverse?).to be true }
    end # wrap_context
  end # describe

  describe '#inverse_metadata' do
    it { expect(instance.inverse_metadata).to be nil }

    wrap_context 'when options[:inverse] is set' do
      it { expect(instance.inverse_metadata).to be inverse_metadata }
    end # wrap_context
  end # describe

  describe '#inverse_name' do
    it { expect(instance.inverse_name).to be nil }

    wrap_context 'when options[:inverse] is set' do
      it { expect(instance.inverse_name).to be inverse_name }
    end # wrap_context
  end # describe

  describe '#many?' do
    it { expect(instance.many?).to be false }
  end # describe

  describe '#one?' do
    it { expect(instance.one?).to be false }
  end # describe
end # describe
