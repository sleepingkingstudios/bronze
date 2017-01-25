# spec/bronze/entities/attributes/transforms/symbol_transform_spec.rb

require 'bronze/entities/attributes/transforms/symbol_transform'

RSpec.describe Bronze::Entities::Attributes::Transforms::SymbolTransform do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::instance' do
    it { expect(described_class).to have_reader(:instance) }

    it 'should return a memoized instance' do
      instance = described_class.instance

      expect(instance).to be_a(described_class)
      expect(instance).to be described_class.instance
    end # it
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.denormalize nil).to be nil }
    end # describe

    describe 'with an empty string' do
      let(:str) { '' }

      it { expect(instance.denormalize str).to be == :'' }
    end # describe

    describe 'with a String' do
      let(:str) { 'string_value' }

      it { expect(instance.denormalize str).to be == :string_value }
    end # describe
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be nil }
    end # describe

    describe 'with a String' do
      let(:value) { 'string value' }

      it { expect(instance.normalize value).to be == value }
    end # describe

    describe 'with a Symbol' do
      let(:value) { :symbol_value }

      it { expect(instance.normalize value).to be == value.to_s }
    end # describe
  end # describe
end # describe
