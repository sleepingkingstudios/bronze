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

  shared_context 'when a transform is set' do
    let(:transform_class) do
      Class.new(Bronze::Entities::Transforms::AttributesTransform) do
        attributes :title
      end # class
    end # let
    let(:transform) do
      transform_class.new(entity_class)
    end # let
  end # shared_context

  let(:transform) do
    Bronze::Entities::Transforms::IdentityTransform.new
  end # let
  let(:entity_class) do
    Struct.new(:id, :title)
  end # let
  let(:data)     { {} }
  let(:instance) { described_class.new(data, transform) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
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
      let(:expected) { data }

      it 'should return the results array' do
        results = instance.to_a

        expect(results).to contain_exactly(*expected)
      end # it

      wrap_context 'when a transform is set' do
        let(:expected) do
          super().map { |hsh| instance.transform.denormalize hsh }
        end # let

        it 'should return the results as an array of entities' do
          results = instance.to_a

          expect(results).to contain_exactly(*expected)
        end # it
      end # wrap_context
    end # wrap_context
  end # describe
end # describe
