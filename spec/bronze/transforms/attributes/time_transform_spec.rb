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
      let(:value)    { 395_020_800 }
      let(:expected) { Time.utc(1982, 7, 9) }

      it { expect(transform.denormalize value).to be_a Time }

      it { expect(transform.denormalize value).to be == expected }

      it 'should set the time zone to UTC' do
        expect(transform.denormalize(value).strftime('%:z')).to be == '+00:00'
      end
    end

    describe 'with a Time' do
      let(:value) { Time.utc(1982, 7, 9) }

      it { expect(transform.denormalize value).to be_a Time }

      it { expect(transform.denormalize value).to be == value }

      it 'should set the time zone to UTC' do
        expect(transform.denormalize(value).strftime('%:z')).to be == '+00:00'
      end
    end

    describe 'with a non-utc Time' do
      let(:value) { Time.new(1982, 7, 9, 0, 0, 0, '+05:00') }

      it { expect(transform.denormalize value).to be_a Time }

      it { expect(transform.denormalize value).to be == value }

      it 'should set the time zone to UTC' do
        expect(transform.denormalize(value).strftime('%:z')).to be == '+00:00'
      end
    end

    describe 'with a normalized Time' do
      let(:value)      { Time.utc(1982, 7, 9) }
      let(:normalized) { transform.normalize(value) }

      it { expect(transform.denormalize normalized).to be_a Time }

      it { expect(transform.denormalize normalized).to be == value }

      it 'should set the time zone to UTC' do
        expect(transform.denormalize(normalized).strftime('%:z'))
          .to be == '+00:00'
      end
    end

    describe 'with a normalized non-utc Time' do
      let(:value)      { Time.new(1982, 7, 9, 0, 0, 0, '+05:00') }
      let(:normalized) { transform.normalize(value) }

      it { expect(transform.denormalize normalized).to be_a Time }

      it { expect(transform.denormalize normalized).to be == value }

      it 'should set the time zone to UTC' do
        expect(transform.denormalize(normalized).strftime('%:z'))
          .to be == '+00:00'
      end
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with a Time' do
      let(:value) { Time.utc(1982, 7, 9) }

      it { expect(transform.normalize value).to be == value.to_i }
    end

    describe 'with a non-utc Time' do
      let(:value) { Time.new(1982, 7, 9, 0, 0, 0, '+05:00') }

      it { expect(transform.normalize value).to be == value.utc.to_i }
    end
  end
end
