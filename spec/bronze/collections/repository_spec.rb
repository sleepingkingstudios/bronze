# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/repository'

RSpec.describe Bronze::Collections::Repository do
  subject(:repository) { described_class.new(adapter: adapter) }

  let(:adapter) do
    instance_double(
      Bronze::Collections::Adapter,
      collection_name_for: '',
      collection_names:    %w[authors books magazines publishers]
    )
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:adapter)
    end
  end

  describe '#adapter' do
    include_examples 'should have reader', :adapter, -> { adapter }
  end

  describe '#collection' do
    it 'should define the method' do
      expect(repository)
        .to respond_to(:collection)
        .with(1).argument
        .and_keywords(:name)
    end

    describe 'with nil' do
      let(:error_message) do
        'expected definition to be a collection name or a class, but was nil'
      end

      it 'should raise an error' do
        expect { repository.collection(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object) { Object.new }
      let(:error_message) do
        'expected definition to be a collection name or a class, but was ' \
        "#{object.inspect}"
      end

      it 'should raise an error' do
        expect { repository.collection(object) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a collection name' do
      let(:options)         { {} }
      let(:collection_name) { 'books' }
      let(:collection) do
        repository.collection(collection_name, **options)
      end

      it { expect(collection).to be_a Bronze::Collections::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == collection_name }

      describe 'with name: String' do
        let(:options) { { name: 'publications' } }

        it { expect(collection.name).to be == 'publications' }
      end
    end

    describe 'with an entity class' do
      let(:options)         { {} }
      let(:collection_name) { 'spec__widgets' }
      let(:collection) do
        repository.collection(Spec::Widget, **options)
      end

      example_class 'Spec::Widget'

      before(:example) do
        allow(adapter)
          .to receive(:collection_name_for)
          .with(Spec::Widget)
          .and_return('spec__widgets')
      end

      it { expect(collection).to be_a Bronze::Collections::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == collection_name }

      describe 'with name: String' do
        let(:options) { { name: 'whatsits' } }

        it { expect(collection.name).to be == 'whatsits' }
      end
    end
  end

  describe '#collection_names' do
    it { expect(repository).to respond_to(:collection_names).with(0).arguments }

    it 'should delegate to the query' do
      repository.collection_names

      expect(adapter).to have_received(:collection_names).with(no_args)
    end

    it { expect(repository.collection_names).to be adapter.collection_names }
  end
end
