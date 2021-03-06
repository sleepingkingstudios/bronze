# spec/bronze/collections/collection_builder_spec.rb

require 'bronze/collections/collection_builder'

RSpec.describe Bronze::Collections::CollectionBuilder do
  let(:collection_type) { :resources }
  let(:instance)        { described_class.new collection_type }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.new nil }.
          to raise_error ArgumentError, "collection_type can't be nil"
      end # it
    end # describe
  end # describe

  describe '#build' do
    it { expect(instance).to respond_to(:build).with(0).arguments }

    it 'should raise an error' do
      expect { instance.build }.
        to raise_error described_class::NotImplementedError
    end # it
  end # describe

  describe '#collection_class' do
    include_examples 'should have reader', :collection_class
  end # describe

  describe '#collection_name' do
    include_examples 'should have reader',
      :collection_name,
      ->() { be == collection_type.to_s }

    context 'when the collection type is a denormalized collection name' do
      let(:collection_type) { 'Resource' }

      it { expect(instance.collection_name).to be == 'resources' }
    end # context

    context 'when the collection type is a named resource' do
      let(:collection_type) { String }

      it { expect(instance.collection_name).to be == 'strings' }
    end # context

    context 'when the collection type is a named resource with a namespace' do
      example_class 'Spec::ComplexResource'

      let(:collection_type) { Spec::ComplexResource }

      it { expect(instance.collection_name).to be == 'spec-complex_resources' }
    end # context
  end # describe

  describe '#collection_type' do
    include_examples 'should have reader', :collection_type,
      ->() { be == collection_type }
  end # describe
end # describe
