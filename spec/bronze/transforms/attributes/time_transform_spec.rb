# frozen_string_literal: true

require 'bronze/transforms/attributes/time_transform'

RSpec.describe Bronze::Transforms::Attributes::TimeTransform do
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

    describe 'with an Integer' do
      let(:value) { Time.new(1982, 7, 9) }

      it { expect(transform.denormalize value.to_i).to be == value }
    end

    describe 'with a Time' do
      let(:value) { Time.new(1982, 7, 9) }

      it { expect(transform.denormalize value).to be == value }
    end

    describe 'with a normalized Time' do
      let(:value)      { Time.new(1982, 7, 9) }
      let(:normalized) { transform.normalize(value) }

      it { expect(transform.denormalize(normalized)).to be == value }
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with a Time' do
      let(:value) { Time.new(1982, 7, 9) }

      it { expect(transform.normalize value).to be == value.to_i }
    end
  end
end
