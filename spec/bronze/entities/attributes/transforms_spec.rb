# spec/bronze/entities/attributes/transforms_spec.rb

require 'bigdecimal'
require 'date'

require 'bronze/entities/attributes/transforms'

RSpec.describe Bronze::Entities::Attributes::Transforms do
  describe '::transform_for' do
    it 'should define the method' do
      expect(described_class).to respond_to(:transform_for).with(1).argument
    end # it

    describe 'with an unknown class' do
      it { expect(described_class.transform_for Class.new).to be nil }
    end # describe

    describe 'with BigDecimal' do
      it 'should return a transform' do
        transform = described_class.transform_for BigDecimal

        expect(transform).to be described_class::BigDecimalTransform.instance
      end # it
    end # describe

    describe 'with Date' do
      it 'should return a transform' do
        transform = described_class.transform_for Date

        expect(transform).to be described_class::DateTransform.instance
      end # it
    end # describe

    describe 'with DateTime' do
      it 'should return a transform' do
        transform = described_class.transform_for DateTime

        expect(transform).to be described_class::DateTimeTransform.instance
      end # it
    end # describe

    describe 'with Symbol' do
      it 'should return a transform' do
        transform = described_class.transform_for Symbol

        expect(transform).to be described_class::SymbolTransform.instance
      end # it
    end # describe

    describe 'with Time' do
      it 'should return a transform' do
        transform = described_class.transform_for Time

        expect(transform).to be described_class::TimeTransform.instance
      end # it
    end # describe
  end # describe
end # describe
