# spec/bronze/entities/associations/metadata/references_one_metadata_spec.rb

require 'bronze/entities/associations/metadata/association_metadata_examples'
require 'bronze/entities/associations/metadata/references_one_metadata'
require 'support/example_entity'

# rubocop:disable Metrics/LineLength
RSpec.describe Bronze::Entities::Associations::Metadata::ReferencesOneMetadata do
  # rubocop:enable Metrics/LineLength
  include Spec::Entities::Associations::MetadataExamples

  shared_context 'when options[:inverse] is set' do
    let(:association_options) do
      super().merge :inverse => inverse_name
    end # let
  end # shared_context

  shared_context 'when the inverse is a has_many association' do
    include_context 'when options[:inverse] is set'

    let(:inverse_name) { :books }
    let!(:inverse_metadata) do
      association_class.has_many(
        inverse_name,
        :class_name => 'Spec::Book',
        :inverse => :author
      ) # end let
    end # let
  end # shared_context

  shared_context 'when the inverse is a has_one association' do
    include_context 'when options[:inverse] is set'

    let!(:inverse_metadata) do
      association_class.has_one(
        inverse_name,
        :class_name => 'Spec::Book',
        :inverse => :author
      ) # end let
    end # let
  end # shared_context

  shared_examples 'should validate the inverse metadata' do
    # rubocop:disable RSpec/EmptyExampleGroup
    wrap_context 'when options[:inverse] is set' do
      wrap_examples 'should validate the inverse metadata presence'

      wrap_examples 'should validate the inverse metadata type'
    end # wrap_context
    # rubocop:enable RSpec/EmptyExampleGroup

    wrap_context 'when the inverse is a has_many association' do
      include_examples 'should validate the inverse metadata inverse'
    end # wrap_context

    wrap_context 'when the inverse is a has_one association' do
      include_examples 'should validate the inverse metadata inverse'
    end # wrap_context
  end # shared_examples

  example_class 'Spec::Author', :base_class => Spec::ExampleEntity

  example_class 'Spec::Book', :base_class => Spec::ExampleEntity do |klass|
    klass.foreign_key :author_id
  end # example_class

  let(:association_name)  { :author }
  let(:association_class) { Spec::Author }
  let(:inverse_name)      { :book }
  let(:association_options) do
    {
      :class_name  => association_class.name,
      :foreign_key => :author_id
    } # end hash
  end # let
  let(:entity_class) { Spec::Book }
  let(:instance) do
    described_class.new(entity_class, association_name, association_options)
  end # let

  def build_invalid_inverse_metadata inverse_name
    association_class.references_one(
      inverse_name,
      :class_name  => 'Spec::Book',
      :foreign_key => :book_id
    ) # end references_one
  end # method build_valid_inverse_metadata

  describe '::ASSOCIATION_TYPE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:ASSOCIATION_TYPE).
        with_value(:references_one)
    end # it
  end # describe

  describe '::REQUIRED_KEYS' do
    let(:expected) { %i[foreign_key] }

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
            and_return(keys + %i[required_option])
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

  describe '#foreign_key_metadata' do
    let(:expected) do
      foreign_key = association_options.fetch(:foreign_key)

      entity_class.attributes[foreign_key]
    end # let

    it { expect(instance.foreign_key_metadata).to be expected }
  end # describe

  describe '#foreign_key_reader_name' do
    it 'should return the option value' do
      expect(instance.foreign_key_reader_name).
        to be == association_options.fetch(:foreign_key)
    end # it
  end # describe

  describe '#foreign_key_type' do
    let(:expected) do
      foreign_key = association_options.fetch(:foreign_key)

      entity_class.attributes[foreign_key].type
    end # let

    it 'should return the option value' do
      expect(instance.foreign_key_type).
        to be == expected
    end # it
  end # describe

  describe '#foreign_key_writer_name' do
    let(:expected) do
      :"#{association_options.fetch(:foreign_key)}="
    end # let

    it { expect(instance.foreign_key_writer_name).to be == expected }
  end # describe

  describe '#inverse?' do
    def call_method
      instance.inverse?
    end # method call_method

    it { expect(instance.inverse?).to be false }

    include_examples 'should validate the inverse metadata'

    wrap_context 'when the inverse is a has_many association' do
      it { expect(instance.inverse?).to be true }
    end # wrap_context

    wrap_context 'when the inverse is a has_one association' do
      it { expect(instance.inverse?).to be true }
    end # wrap_context
  end # describe

  describe '#inverse_metadata' do
    def call_method
      instance.inverse_metadata
    end # method call_method

    it { expect(instance.inverse_metadata).to be nil }

    include_examples 'should validate the inverse metadata'

    wrap_context 'when the inverse is a has_many association' do
      it { expect(instance.inverse_metadata).to be inverse_metadata }
    end # wrap_context

    wrap_context 'when the inverse is a has_one association' do
      it { expect(instance.inverse_metadata).to be inverse_metadata }
    end # wrap_context
  end # describe

  describe '#inverse_name' do
    def call_method
      instance.inverse_name
    end # method call_method

    it { expect(instance.inverse_name).to be nil }

    include_examples 'should validate the inverse metadata'

    wrap_context 'when the inverse is a has_many association' do
      it { expect(instance.inverse_name).to be inverse_name }
    end # wrap_context

    wrap_context 'when the inverse is a has_one association' do
      it { expect(instance.inverse_name).to be inverse_name }
    end # wrap_context
  end # describe

  describe '#many?' do
    it { expect(instance.many?).to be false }
  end # describe

  describe '#one?' do
    it { expect(instance.one?).to be true }
  end # describe

  describe '#predicate_name' do
    include_examples 'should have reader',
      :predicate_name,
      ->() { be == :"#{association_name}?" }
  end # describe
end # describe
