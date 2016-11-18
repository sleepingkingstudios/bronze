# spec/bronze/entities/attributes/attribute_builder_spec.rb

require 'bronze/entities/attributes/attribute_builder'
require 'bronze/entities/attributes/attribute_metadata'

require 'bronze/entities/attributes/attributes_examples'

RSpec.describe Bronze::Entities::Attributes::AttributeBuilder do
  include Spec::Entities::Attributes::AttributesExamples

  let(:entity_class) do
    Class.new do
      def initialize
        @attributes = {}
      end # constructor
    end # class
  end # let
  let(:entity)   { entity_class.new }
  let(:instance) { described_class.new(entity_class) }

  describe '::VALID_OPTIONS' do
    it { expect(described_class).to have_immutable_constant :VALID_OPTIONS }

    it 'should list the valid options' do
      expect(described_class::VALID_OPTIONS).to be == %w(
        allow_nil
        default
        read_only
      ) # end array
    end # it
  end # describe

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe

  describe '#build' do
    shared_context 'when the attribute has been defined' do
      let!(:metadata) do
        instance.build attribute_name, attribute_type, attribute_opts
      end # let!
    end # shared_context

    let(:attribute_name) { :title }
    let(:attribute_type) { String }
    let(:attribute_opts) { {} }

    it { expect(instance).to respond_to(:build).with(2..3).arguments }

    it 'should validate the attribute name', :aggregate_failures do
      expect { instance.build nil, attribute_type }.
        to raise_error described_class::Error,
          "attribute name can't be blank"

      expect { instance.build '', attribute_type }.
        to raise_error described_class::Error,
          "attribute name can't be blank"

      expect { instance.build Object.new, attribute_type }.
        to raise_error described_class::Error,
          'attribute name must be a String or Symbol'
    end # it

    it 'should validate the attribute type', :aggregate_failures do
      expect { instance.build attribute_name, nil }.
        to raise_error described_class::Error,
          "attribute type can't be blank"

      expect { instance.build attribute_name, Object.new }.
        to raise_error described_class::Error,
          'attribute type must be a Class'
    end # it

    it 'should validate the attribute options' do
      opts = { :invalid_option => true }

      expect { instance.build attribute_name, attribute_type, opts }.
        to raise_error described_class::Error,
          'invalid attribute option :invalid_option'
    end # it

    describe 'with a valid attribute name and attribute type' do
      let(:attribute_type_class) do
        Bronze::Entities::Attributes::AttributeType
      end # let

      it 'should return the metadata' do
        metadata = instance.build attribute_name, attribute_type
        mt_class = Bronze::Entities::Attributes::AttributeMetadata

        expect(metadata).to be_a mt_class
        expect(metadata.attribute_name).to be == attribute_name
        expect(metadata.attribute_type).to be_a attribute_type_class
        expect(metadata.object_type).to be == attribute_type

        expect(metadata.allow_nil?).to be false
        expect(metadata.default).to be nil
        expect(metadata.read_only?).to be false
      end # it

      describe 'with :allow_nil => true' do
        it 'should return the metadata' do
          metadata =
            instance.build attribute_name, attribute_type, :allow_nil => true

          expect(metadata.allow_nil?).to be true
        end # it
      end # describe

      wrap_context 'when the attribute has been defined' do
        let(:updated_value) { 'Dream of a Red Chamber' }

        include_examples 'should define attribute', :title, String

        describe 'with :default => lambda' do
          let(:default) do
            books_count = 0

            ->() { "Book #{books_count += 1}" }
          end # let
          let(:attribute_opts) { super().merge :default => default }
          let(:expected)       { ['Book 1', 'Book 2', 'Book 3'] }

          it 'should set the title to the default value' do
            books = Array.new(3) { entity_class.new }

            expect(books.map(&:title)).to be == expected
          end # it
        end # describe

        describe 'with :default => value' do
          let(:attribute_opts) { super().merge :default => 'Untitled Book' }

          it { expect(entity.title).to be == attribute_opts[:default] }

          context 'when a value is set' do
            before(:example) { entity.title = 'The Lay of Beleriand' }

            describe 'with nil' do
              it 'should set the value to the default' do
                expect { entity.title = nil }.
                  to change(entity, :title).
                  to be == attribute_opts[:default]
              end # describe
            end # describe
          end # context
        end # describe

        describe 'with :read_only => true' do
          let(:attribute_opts) { super().merge :read_only => true }

          include_examples 'should define attribute',
            :title,
            String,
            :read_only => true
        end # describe
      end # wrap_context
    end # describe
  end # describe
end # describe
