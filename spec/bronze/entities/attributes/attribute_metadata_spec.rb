# spec/bronze/entities/attributes/attribute_metadata_spec.rb

require 'bronze/entities/attributes/attribute_metadata'

RSpec.describe Bronze::Entities::Attributes::AttributeMetadata do
  let(:attribute_name)    { :title }
  let(:attribute_type)    { String }
  let(:attribute_options) { {} }
  let(:instance) do
    described_class.new(attribute_name, attribute_type, attribute_options)
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(3).arguments }
  end # describe

  describe '#allow_nil?' do
    include_examples 'should have predicate', :allow_nil?, false

    context 'when the allow nil flag is set to true' do
      let(:attribute_options) { { :allow_nil => true } }

      it { expect(instance.allow_nil?).to be true }
    end # context
  end # describe

  describe '#attribute_name' do
    include_examples 'should have reader', :attribute_name, lambda {
      be == attribute_name
    } # end lambda
  end # describe

  describe '#attribute_options' do
    include_examples 'should have reader', :attribute_options, lambda {
      be == attribute_options
    } # end lambda
  end # describe

  describe '#attribute_type' do
    let(:attribute_type_class) do
      Bronze::Entities::Attributes::AttributeType
    end # let

    include_examples 'should have reader', :attribute_type

    it 'should be an attribute type' do
      attr_type = instance.attribute_type

      expect(attr_type).to be_a attribute_type_class
      expect(attr_type.object_type).to be String
    end # it
  end # describe

  describe '#default' do
    include_examples 'should have reader', :default, nil

    it { expect(instance).to alias_method(:default).as(:default_value) }

    context 'when the default value is set to a lambda' do
      let(:default) do
        int = 0

        ->() { int += 1 }
      end # let
      let(:attribute_options) { { :default => default } }

      it 'should call the lambda' do
        defaults = Array.new(3) { instance.default }

        expect(defaults).to be == [1, 2, 3]
      end # it
    end # context

    context 'when the default value is set to a value' do
      let(:attribute_options) { { :default => :value } }

      it { expect(instance.default).to be == attribute_options[:default] }
    end # context
  end # describe

  describe '#default?' do
    include_examples 'should have predicate', :default?, false

    context 'when the default value is set to false' do
      let(:attribute_options) { { :default => false } }

      it { expect(instance.default?).to be true }
    end # context

    context 'when the default value is set to a lambda' do
      let(:attribute_options) { { :default => ->() {} } }

      it { expect(instance.default?).to be true }
    end # context

    context 'when the default value is set to nil' do
      let(:attribute_options) { { :default => nil } }

      it { expect(instance.default?).to be false }
    end # context

    context 'when the default value is set to a value' do
      let(:attribute_options) { { :default => :value } }

      it { expect(instance.default?).to be true }
    end # context
  end # describe

  describe '#matches?' do
    it 'should delegate the method' do
      expect(instance).
        to delegate_method(:matches?).
        to(instance.attribute_type).
        with_arguments(double('object'))
    end # it
  end # describe

  describe '#object_type' do
    include_examples 'should have reader', :object_type, ->() { attribute_type }
  end # describe

  describe '#read_only?' do
    include_examples 'should have predicate', :read_only?, false

    context 'when the read-only flag is set to true' do
      let(:attribute_options) { { :read_only => true } }

      it { expect(instance.read_only?).to be true }
    end # context
  end # describe

  describe '#reader_name' do
    include_examples 'should have reader', :reader_name, lambda {
      be == attribute_name
    } # end lambda
  end # describe

  describe '#writer_name' do
    include_examples 'should have reader', :writer_name, lambda {
      be == :"#{attribute_name}="
    } # end lambda
  end # describe
end # describe
