# spec/bronze/entities/attributes/transforms/big_decimal_transform_spec.rb

require 'bronze/entities/attributes/transforms/big_decimal_transform'

RSpec.describe Bronze::Entities::Attributes::Transforms::BigDecimalTransform do
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

      it { expect(instance.denormalize str).to be == BigDecimal.new('0.0') }
    end # describe

    describe 'with "Infinity"' do
      let(:str) { 'Infinity' }

      it 'should return a BigDecimal' do
        dec = instance.denormalize str

        expect(dec).to be_a(BigDecimal)
        expect(dec.infinite?).to be 1
      end # it
    end # describe

    describe 'with "NaN"' do
      let(:str) { 'NaN' }

      it 'should return a BigDecimal' do
        dec = instance.denormalize str

        expect(dec).to be_a(BigDecimal)
        expect(dec.nan?).to be true
      end # it
    end # describe

    describe 'with an integer string' do
      let(:str) { '5' }

      it { expect(instance.denormalize str).to be == BigDecimal.new(str) }
    end # describe

    describe 'with a decimal string' do
      let(:str) { '5.0' }

      it { expect(instance.denormalize str).to be == BigDecimal.new(str) }
    end # describe

    describe 'with an exponential string' do
      let(:str) { '9.001E3' }

      it { expect(instance.denormalize str).to be == BigDecimal.new(str) }
    end # describe

    describe 'with an invalid string' do
      let(:str) { 'invalid' }

      it { expect(instance.denormalize str).to be == BigDecimal.new('0.0') }
    end # describe

    describe 'with a BigDecimal' do
      let(:value) { BigDecimal.new('3.14') }

      it { expect(instance.denormalize value).to be == value }
    end # describe
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be nil }
    end # describe

    describe 'with a BigDecimal' do
      let(:value) { BigDecimal.new('3.14') }

      it { expect(instance.normalize value).to be == value.to_s }
    end # describe
  end # describe
end # describe
