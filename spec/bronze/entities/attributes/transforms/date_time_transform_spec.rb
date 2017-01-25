# spec/bronze/entities/attributes/transforms/date_time_transform_spec.rb

require 'bronze/entities/attributes/transforms/date_transform'

RSpec.describe Bronze::Entities::Attributes::Transforms::DateTimeTransform do
  shared_context 'when a custom date format is defined' do
    let(:format) { '%B %-d, %Y at %T' }
  end # shared_context

  let(:format)   { described_class::Iso8601 }
  let(:instance) { described_class.new format }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '::instance' do
    it { expect(described_class).to have_reader(:instance) }

    it 'should return a memoized instance' do
      instance = described_class.instance

      expect(instance).to be_a(described_class)
      expect(instance).to be described_class.instance

      expect(instance.format).to be == described_class::Iso8601
    end # it
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.denormalize nil).to be nil }
    end # describe

    describe 'with an empty string' do
      let(:str) { '' }

      it { expect(instance.denormalize str).to be nil }
    end # describe

    describe 'with a String' do
      let(:str) { '1982-07-09T12:30:00+0000' }

      it 'should return a DateTime' do
        date = instance.denormalize str

        expect(date.year).to be 1982
        expect(date.month).to be 7
        expect(date.day).to be 9
        expect(date.hour).to be 12
        expect(date.minute).to be 30
        expect(date.second).to be 0
        expect(date.zone).to be == '+00:00'
      end # it

      wrap_context 'when a custom date format is defined' do
        let(:str) { 'July 9, 1982 at 12:30:00' }

        it 'should return a Date' do
          date = instance.denormalize str

          expect(date.year).to be 1982
          expect(date.month).to be 7
          expect(date.day).to be 9
          expect(date.hour).to be 12
          expect(date.minute).to be 30
          expect(date.second).to be 0
          expect(date.zone).to be == '+00:00'
        end # it
      end # method wrap_context
    end # describe

    describe 'with a Date' do
      let(:value) { DateTime.new(1982, 7, 9, 12, 30, 0) }

      it { expect(instance.denormalize value).to be == value }

      wrap_context 'when a custom date format is defined' do
        it { expect(instance.denormalize value).to be == value }
      end # method wrap_context
    end # describe
  end # describe

  describe '#format' do
    include_examples 'should have reader', :format, ->() { be == format }

    wrap_context 'when a custom date format is defined' do
      it { expect(instance.format).to be == format }
    end # wrap_context
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be nil }
    end # describe

    describe 'with a Date' do
      let(:value)    { DateTime.new(1982, 7, 9, 12, 30, 0) }
      let(:expected) { '1982-07-09T12:30:00+0000' }

      it { expect(instance.normalize value).to be == expected }

      wrap_context 'when a custom date format is defined' do
        let(:expected) { 'July 9, 1982 at 12:30:00' }

        it { expect(instance.normalize value).to be == expected }
      end # method wrap_context
    end # describe
  end # describe
end # describe
