# frozen_string_literal: true

require 'date'

require 'bronze/transforms/attributes/date_transform'

RSpec.describe Bronze::Transforms::Attributes::DateTransform do
  shared_context 'when a custom date format is defined' do
    let(:custom_format) { '%B %-d, %Y' }
    let(:transform)     { described_class.new(custom_format) }
  end

  subject(:transform) { described_class.new }

  describe '::ISO_8601' do
    it 'should define the constant' do
      expect(described_class)
        .to define_constant(:ISO_8601)
        .immutable
        .with_value('%F')
    end
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
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

      it { expect(transform.denormalize str).to be nil }
    end

    describe 'with a String' do
      let(:str)  { '1982-07-09' }
      let(:date) { transform.denormalize(str) }

      it { expect(transform.denormalize str).to be_a Date }

      it { expect(date.year).to be 1982 }

      it { expect(date.month).to be 7 }

      it { expect(date.day).to be 9 }
    end

    describe 'with a Date' do
      let(:value) { Date.new(1982, 7, 9) }

      it { expect(transform.denormalize value).to be value }
    end

    describe 'with a normalized Date' do
      let(:date)       { Date.new(1982, 7, 9) }
      let(:normalized) { transform.normalize(date) }

      it { expect(transform.denormalize(normalized)).to be == date }
    end

    wrap_context 'when a custom date format is defined' do
      describe 'with a String' do
        let(:str)  { 'July 9, 1982' }
        let(:date) { transform.denormalize(str) }

        it { expect(transform.denormalize str).to be_a Date }

        it { expect(date.year).to be 1982 }

        it { expect(date.month).to be 7 }

        it { expect(date.day).to be 9 }
      end

      describe 'with a normalized Date' do
        let(:date)       { Date.new(1982, 7, 9) }
        let(:normalized) { transform.normalize(date) }

        it { expect(transform.denormalize(normalized)).to be == date }
      end
    end
  end

  describe '#format' do
    include_examples 'should have reader', :format, described_class::ISO_8601

    wrap_context 'when a custom date format is defined' do
      it { expect(transform.format).to be == custom_format }
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with a Date' do
      let(:value) { Date.new(1982, 7, 9) }

      it { expect(transform.normalize value).to be == '1982-07-09' }
    end

    wrap_context 'when a custom date format is defined' do
      describe 'with a Date' do
        let(:value) { Date.new(1982, 7, 9) }

        it { expect(transform.normalize value).to be == 'July 9, 1982' }
      end
    end
  end
end
