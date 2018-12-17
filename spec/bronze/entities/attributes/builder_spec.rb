# frozen_string_literal: true

require 'bronze/entities/attributes/builder'
require 'bronze/transforms/transform'

RSpec.describe Bronze::Entities::Attributes::Builder do
  subject(:builder) { described_class.new(entity_class) }

  let(:entity_class) { Spec::ExampleEntity }

  example_class 'Spec::ExampleEntity' do |klass|
    klass.send :define_method, :get_attribute, ->(_name) {}
    klass.send :define_method, :set_attribute, ->(_name, _value) {}
  end

  describe '::VALID_OPTIONS' do
    let(:expected) do
      %w[
        allow_nil
        default
        foreign_key
        primary_key
        read_only
        transform
      ]
    end

    it { expect(described_class).to have_immutable_constant :VALID_OPTIONS }

    it 'should list the valid options' do
      expect(described_class::VALID_OPTIONS).to be == expected
    end
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
    end
  end

  describe '#build' do
    shared_examples 'should define the attribute' do |options = {}|
      let(:metadata) { build_attribute }
      let(:entity)   { entity_class.new }

      def build_attribute
        builder.build(attribute_name, attribute_type, attribute_opts)
      end

      it 'should return the metadata' do
        expect(build_attribute)
          .to be_a Bronze::Entities::Attributes::Metadata
      end

      it 'should set the attribute name' do
        expect(metadata.name).to be == attribute_name.intern
      end

      it 'should set the attribute options' do
        expect(metadata.options).to be == attribute_opts
      end

      it 'should set the attribute type' do
        expect(metadata.type).to be == attribute_type
      end

      if options[:allow_nil]
        it { expect(metadata.allow_nil?).to be true }
      else
        it { expect(metadata.allow_nil?).to be false }
      end

      if options[:default]
        it { expect(metadata.default).to be == default_value }

        it { expect(metadata.default?).to be true }
      else
        it { expect(metadata.default).to be nil }

        it { expect(metadata.default?).to be false }
      end

      if options[:foreign_key]
        it { expect(metadata.foreign_key?).to be true }
      else
        it { expect(metadata.foreign_key?).to be false }
      end

      if options[:primary_key]
        it { expect(metadata.primary_key?).to be true }
      else
        it { expect(metadata.primary_key?).to be false }
      end

      if options[:read_only]
        it { expect(metadata.read_only?).to be true }
      else
        it { expect(metadata.read_only?).to be false }
      end

      if options[:transform]
        it { expect(metadata.transform).to be attribute_opts[:transform] }
      else
        it { expect(metadata.transform).to be nil }
      end

      context 'when the attribute is defined' do
        let(:value) { 'attribute value' }

        before(:example) do
          build_attribute

          allow(entity).to receive(:get_attribute).and_return(value)
          allow(entity).to receive(:set_attribute)
        end

        it 'should define the reader method' do
          expect(entity).to have_reader(attribute_name)
        end

        it 'should delegate the reader to #get_attribute' do
          entity.send(attribute_name)

          expect(entity)
            .to have_received(:get_attribute)
            .with(attribute_name.intern)
        end

        it 'should return the value from #get_attribute' do
          expect(entity.send(attribute_name)).to be value
        end

        # rubocop:disable RSpec/RepeatedDescription
        if options.fetch(:read_only, false)
          it 'should define the writer method' do
            expect(entity)
              .to respond_to(:"#{attribute_name}=", true)
              .with(1).argument
          end

          it 'should set the writer method as private' do
            expect(entity).not_to respond_to(:"#{attribute_name}=")
          end
        else
          it 'should define the writer method' do
            expect(entity).to have_writer(:"#{attribute_name}=")
          end
        end
        # rubocop:enable RSpec/RepeatedDescription

        it 'should delegate the writer to #set_attribute' do
          entity.send(:"#{attribute_name}=", value)

          expect(entity)
            .to have_received(:set_attribute)
            .with(attribute_name.intern, value)
        end
      end
    end

    let(:attribute_name) { :title }
    let(:attribute_type) { String }
    let(:attribute_opts) { {} }

    it { expect(builder).to respond_to(:build).with(2..3).arguments }

    describe 'with a nil attribute name' do
      let(:error_message) do
        'expected attribute name to be a String or Symbol, but was nil'
      end

      it 'should raise an error' do
        expect { builder.build nil, attribute_type }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty attribute name' do
      let(:error_message) { "attribute name can't be blank" }

      it 'should raise an error' do
        expect { builder.build '', attribute_type }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an invalid attribute name' do
      let(:object) { Object.new }
      let(:error_message) do
        'expected attribute name to be a String or Symbol, but was ' \
        "#{object.inspect}"
      end

      it 'should raise an error' do
        expect { builder.build object, attribute_type }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an invalid attribute option' do
      let(:attribute_opts) { super().merge(invalid_option: true) }
      let(:error_message)  { 'invalid attribute option :invalid_option' }

      it 'should raise an error' do
        expect { builder.build attribute_name, attribute_type, attribute_opts }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a String attribute name' do
      let(:attribute_name) { 'title' }

      include_examples 'should define the attribute'
    end

    describe 'with a Symbol attribute name' do
      let(:attribute_name) { :title }

      include_examples 'should define the attribute'
    end

    describe 'with allow_nil: true' do
      let(:attribute_opts) { super().merge allow_nil: true }

      include_examples 'should define the attribute', allow_nil: true
    end

    describe 'with default: block' do
      let(:default_value)  { 'default' }
      let(:attribute_opts) do
        value = default_value

        super().merge default: -> { value }
      end

      include_examples 'should define the attribute', default: true
    end

    describe 'with default: value' do
      let(:default_value)  { 'default' }
      let(:attribute_opts) { super().merge default: default_value }

      include_examples 'should define the attribute', default: true
    end

    describe 'with foreign_key: true' do
      let(:attribute_opts) { super().merge foreign_key: true }

      include_examples 'should define the attribute', foreign_key: true
    end

    describe 'with primary_key: true' do
      let(:attribute_opts) { super().merge primary_key: true }

      include_examples 'should define the attribute', primary_key: true
    end

    describe 'with read_only: true' do
      let(:attribute_opts) { super().merge read_only: true }

      include_examples 'should define the attribute', read_only: true
    end

    describe 'with transform: value' do
      let(:transform)      { Bronze::Transforms::Transform.new }
      let(:attribute_opts) { super().merge transform: transform }

      include_examples 'should define the attribute', transform: true
    end

    context 'when the entity class has many attributes' do
      let(:attribute_name) { :publisher }

      before(:example) do
        described_class.new(Spec::ExampleEntity).build(:title,      String)
        described_class.new(Spec::ExampleEntity).build(:author,     String)
        described_class.new(Spec::ExampleEntity).build(:page_count, Integer)
      end

      include_examples 'should define the attribute'
    end

    context 'when the entity class has a parent class with attributes' do
      let(:entity_class)   { Spec::ExampleSubclass }
      let(:parent_entity)  { Spec::ExampleEntity.new }
      let(:attribute_name) { :publisher }

      example_class 'Spec::ExampleSubclass', 'Spec::ExampleEntity'

      before(:example) do
        described_class.new(Spec::ExampleEntity).build(:title, String)
      end

      include_examples 'should define the attribute'

      it { expect(parent_entity).not_to respond_to(attribute_name) }

      it { expect(parent_entity).not_to respond_to(:"#{attribute_name}=") }
    end
  end

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, -> { entity_class }
  end
end
