# frozen_string_literal: true

require 'bronze/transforms/attributes/date_time_transform'

RSpec.describe Bronze::Transforms::Attributes::DateTimeTransform do
  shared_context 'when a custom date format is defined' do
    let(:custom_format) { '%B %-d, %Y at %T' }
    let(:transform)     { described_class.new(custom_format) }
  end

  subject(:transform) { described_class.new }

  describe '::ISO_8601' do
    it 'should define the constant' do
      expect(described_class)
        .to define_constant(:ISO_8601)
        .immutable
        .with_value('%FT%T%z')
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
      let(:str)      { '1982-07-09T12:30:00+0000' }
      let(:datetime) { transform.denormalize(str) }

      it { expect(transform.denormalize str).to be_a DateTime }

      it { expect(datetime.year).to be 1982 }

      it { expect(datetime.month).to be 7 }

      it { expect(datetime.day).to be 9 }

      it { expect(datetime.hour).to be 12 }

      it { expect(datetime.minute).to be 30 }

      it { expect(datetime.second).to be 0 }

      it { expect(datetime.zone).to be == '+00:00' }
    end

    describe 'with a DateTime' do
      let(:value) { DateTime.new(1982, 7, 9, 12, 30, 0) }

      it { expect(transform.denormalize value).to be == value }
    end

    describe 'with a normalized DateTime' do
      let(:datetime)   { DateTime.new(1982, 7, 9, 12, 30, 0) }
      let(:normalized) { transform.normalize(datetime) }

      it { expect(transform.denormalize(normalized)).to be == datetime }
    end

    wrap_context 'when a custom date format is defined' do
      describe 'with a String' do
        let(:str)      { 'July 9, 1982 at 12:30:00' }
        let(:datetime) { transform.denormalize(str) }

        it { expect(transform.denormalize str).to be_a DateTime }

        it { expect(datetime.year).to be 1982 }

        it { expect(datetime.month).to be 7 }

        it { expect(datetime.day).to be 9 }

        it { expect(datetime.hour).to be 12 }

        it { expect(datetime.minute).to be 30 }

        it { expect(datetime.second).to be 0 }

        it { expect(datetime.zone).to be == '+00:00' }
      end

      describe 'with a normalized DateTime' do
        let(:datetime)   { DateTime.new(1982, 7, 9, 12, 30, 0) }
        let(:normalized) { transform.normalize(datetime) }

        it { expect(transform.denormalize(normalized)).to be == datetime }
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
      let(:value)    { DateTime.new(1982, 7, 9, 12, 30, 0) }
      let(:expected) { '1982-07-09T12:30:00+0000' }

      it { expect(transform.normalize value).to be == expected }
    end

    wrap_context 'when a custom date format is defined' do
      describe 'with a Date' do
        let(:value)    { DateTime.new(1982, 7, 9, 12, 30, 0) }
        let(:expected) { 'July 9, 1982 at 12:30:00' }

        it { expect(transform.normalize value).to be == expected }
      end
    end
  end
end
