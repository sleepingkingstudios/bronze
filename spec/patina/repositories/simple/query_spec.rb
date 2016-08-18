# spec/patina/repositories/simple/query_spec.rb

require 'patina/repositories/simple/query'

RSpec.describe Patina::Repositories::Simple::Query do
  shared_context 'when the data contains many items' do
    let(:data) do
      [
        { :id => '1', :title => 'The Fellowship of the Ring' },
        { :id => '2', :title => 'The Two Towers' },
        { :id => '3', :title => 'The Return of the King' }
      ] # end array
    end # let
  end # shared_context

  let(:data)     { {} }
  let(:instance) { described_class.new(data) }

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

      it 'should return results as read-only' do
        results = instance.to_a

        expect { results << { :title => 'The Hobbit' } }.
          to raise_error RuntimeError, "can't modify frozen Array"

        expect { results.last[:title] = 'The Revenge of the Sith' }.
          to raise_error RuntimeError, "can't modify frozen Hash"
      end # it
    end # wrap_context
  end # describe
end # describe
