# frozen_string_literal: true

require 'bronze/transforms/attributes/symbol_transform'

RSpec.describe Bronze::Transforms::Attributes::SymbolTransform do
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

      it { expect(transform.denormalize str).to be == :'' }
    end

    describe 'with a String' do
      let(:str) { 'string_value' }

      it { expect(transform.denormalize str).to be == :string_value }
    end

    describe 'with a Symbol' do
      let(:value) { :symbol_value }

      it { expect(transform.denormalize value).to be == value }
    end

    describe 'with a normalized Symbol' do
      let(:value)      { :symbol_value }
      let(:normalized) { transform.normalize(value) }

      it { expect(transform.denormalize(normalized)).to be == value }
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with a String' do
      let(:value) { 'string value' }

      it { expect(transform.normalize value).to be == value }
    end

    describe 'with a Symbol' do
      let(:value) { :symbol_value }

      it { expect(transform.normalize value).to be == value.to_s }
    end
  end
end
