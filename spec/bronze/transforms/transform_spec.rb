# spec/bronze/transforms/transform_spec.rb

require 'bronze/transforms/transform'

RSpec.describe Bronze::Transforms::Transform do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    it 'should raise an error' do
      expect { instance.denormalize Object.new }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :denormalize"
    end # it
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    it 'should raise an error' do
      expect { instance.normalize Object.new }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :normalize"
    end # it
  end # describe
end # describe
