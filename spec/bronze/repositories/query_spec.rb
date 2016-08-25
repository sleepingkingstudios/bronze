# spec/bronze/repositories/query_spec.rb

require 'bronze/repositories/query'
require 'bronze/repositories/query_examples'

RSpec.describe Bronze::Repositories::Query do
  include Spec::Repositories::QueryExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Query interface'

  describe '#count' do
    it 'should raise an error' do
      expect { instance.count }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :count"
    end # it
  end # describe

  describe '#to_a' do
    it 'should raise an error' do
      expect { instance.to_a }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :find_each"
    end # it
  end # describe

  describe '#transform' do
    it { expect(instance.transform).to be nil }
  end # describe
end # describe
