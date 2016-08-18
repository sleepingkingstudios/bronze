# spec/bronze/repositories/reference_query_spec.rb

require 'bronze/repositories/reference_query'

RSpec.describe Spec::ReferenceQuery do
  shared_context 'when the data contains many items' do
    let(:data) do
      [
        { :title => 'The Fellowship of the Ring' },
        { :title => 'The Two Towers' },
        { :title => 'The Return of the King' }
      ] # end array
    end # let
  end # shared_context

  let(:data)     { [] }
  let(:instance) { described_class.new data }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it { expect(instance.count).to be 0 }

    wrap_context 'when the data contains many items' do
      it { expect(instance.count).to be data.count }
    end # wrap_context
  end # describe

  describe '#to_a' do
    it { expect(instance).to respond_to(:to_a).with(0).arguments }

    it 'should return an empty results array' do
      results = instance.to_a

      expect(results).to be == []
    end # it

    wrap_context 'when the data contains many items' do
      it 'should return the results array' do
        results = instance.to_a

        expect(results).to contain_exactly(*data)
      end # it
    end # wrap_context
  end # describe
end # describe