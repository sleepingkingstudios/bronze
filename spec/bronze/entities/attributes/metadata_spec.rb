# frozen_string_literal: true

require 'bronze/entities/attributes/metadata'

RSpec.describe Bronze::Entities::Attributes::Metadata do
  subject(:metadata) do
    described_class.new(name, type, options)
  end

  let(:name)    { :title }
  let(:type)    { String }
  let(:options) { {} }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(3).arguments }
  end

  describe '#allow_nil?' do
    include_examples 'should have predicate', :allow_nil?, false

    context 'when the allow nil flag is set to true' do
      let(:options) { { allow_nil: true } }

      it { expect(metadata.allow_nil?).to be true }
    end
  end

  describe '#default' do
    include_examples 'should have reader', :default, nil

    it { expect(metadata).to alias_method(:default).as(:default_value) }

    context 'when the default value is set to a lambda' do
      let(:default) do
        int = 0

        -> { int += 1 }
      end
      let(:options) { { default: default } }

      it 'should call the lambda' do
        defaults = Array.new(3) { metadata.default }

        expect(defaults).to be == [1, 2, 3]
      end
    end

    context 'when the default value is set to a value' do
      let(:options) { { default: :value } }

      it { expect(metadata.default).to be == options[:default] }
    end
  end

  describe '#default?' do
    include_examples 'should have predicate', :default?, false

    context 'when the default value is set to nil' do
      let(:options) { { default: nil } }

      it { expect(metadata.default?).to be false }
    end

    context 'when the default value is set to false' do
      let(:options) { { default: false } }

      it { expect(metadata.default?).to be true }
    end

    context 'when the default value is set to a lambda' do
      let(:options) { { default: -> {} } }

      it { expect(metadata.default?).to be true }
    end

    context 'when the default value is set to a value' do
      let(:options) { { default: :value } }

      it { expect(metadata.default?).to be true }
    end
  end

  describe '#foreign_key?' do
    include_examples 'should have predicate', :foreign_key?, false

    context 'when the foreign key flag is set to true' do
      let(:options) { { foreign_key: true } }

      it { expect(metadata.foreign_key?).to be true }
    end
  end

  describe '#name' do
    include_examples 'should have reader',
      :name,
      -> { be == name }
  end

  describe '#options' do
    include_examples 'should have reader', :options, -> { be == options }
  end

  describe '#read_only?' do
    include_examples 'should have predicate', :read_only?, false

    context 'when the read-only flag is set to true' do
      let(:options) { { read_only: true } }

      it { expect(metadata.read_only?).to be true }
    end
  end

  describe '#reader_name' do
    include_examples 'should have reader',
      :reader_name,
      -> { be == name }
  end

  describe '#type' do
    include_examples 'should have reader',
      :type,
      -> { be == type }
  end

  describe '#writer_name' do
    include_examples 'should have reader',
      :writer_name,
      -> { be == :"#{name}=" }
  end
end
