# spec/bronze/entities/attributes/metadata_spec.rb

require 'bronze/entities/attributes/metadata'

RSpec.describe Bronze::Entities::Attributes::Metadata do
  let(:attribute_name)    { :title }
  let(:attribute_type)    { String }
  let(:attribute_options) { {} }
  let(:instance) do
    described_class.new(attribute_name, attribute_type, attribute_options)
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(3).arguments }
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
    include_examples 'should have reader', :attribute_type, lambda {
      be == attribute_type
    } # end lambda
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
