# spec/bronze/repositories/query_spec.rb

require 'bronze/repositories/query'

RSpec.describe Bronze::Repositories::Query do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it 'should raise an error' do
      expect { instance.count }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :count"
    end # it
  end # describe

  describe '#to_a' do
    it { expect(instance).to respond_to(:to_a).with(0).arguments }

    it 'should raise an error' do
      expect { instance.to_a }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :find_each"
    end # it
  end # describe

  describe '#transform' do
    include_examples 'should have reader', :transform, nil
  end # describe
end # describe
