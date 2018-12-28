# frozen_string_literal: true

require 'bronze/transforms/attributes/big_decimal_transform'

RSpec.describe Bronze::Transforms::Attributes::BigDecimalTransform do
  subject(:transform) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '::instance' do
    it { expect(described_class).to have_reader(:instance) }

    it { expect(described_class.instance).to be_a described_class }

    it 'should return a memoized instance' do
      transform = described_class.instance

      3.times { expect(described_class.instance).to be transform }
    end
  end

  describe '#denormalize' do
    it { expect(transform).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.denormalize nil).to be nil }
    end

    describe 'with an empty string' do
      let(:str) { '' }

      it { expect(transform.denormalize str).to be == BigDecimal('0.0') }
    end

    describe 'with "Infinity"' do
      let(:str) { 'Infinity' }

      it { expect(transform.denormalize str).to be_a BigDecimal }

      it { expect(transform.denormalize(str).infinite?).to be 1 }
    end

    describe 'with "NaN"' do
      let(:str) { 'NaN' }

      it { expect(transform.denormalize str).to be_a BigDecimal }

      it { expect(transform.denormalize(str).nan?).to be true }
    end

    describe 'with an integer string' do
      let(:str) { '5' }

      it { expect(transform.denormalize str).to be == BigDecimal(str) }
    end

    describe 'with a decimal string' do
      let(:str) { '5.0' }

      it { expect(transform.denormalize str).to be == BigDecimal(str) }
    end

    describe 'with an exponential string' do
      let(:str) { '9.001E3' }

      it { expect(transform.denormalize str).to be == BigDecimal(str) }
    end

    describe 'with an invalid string' do
      let(:str) { 'invalid' }

      it { expect(transform.denormalize str).to be == BigDecimal('0.0') }
    end

    describe 'with a BigDecimal' do
      let(:value) { BigDecimal('3.14') }

      it { expect(transform.denormalize value).to be == value }
    end

    describe 'with a normalized BigDecimal' do
      let(:value)      { BigDecimal('3.14') }
      let(:normalized) { transform.normalize(value) }

      it { expect(transform.denormalize(normalized)).to be == value }
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with a BigDecimal' do
      let(:value) { BigDecimal('3.14') }

      it { expect(transform.normalize value).to be == value.to_s }
    end
  end
end
