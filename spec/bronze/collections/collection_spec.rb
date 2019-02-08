# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/collection'
require 'bronze/collections/query'

RSpec.describe Bronze::Collections::Collection do
  subject(:collection) { described_class.new(definition, adapter: adapter) }

  let(:definition) { 'books' }
  let(:adapter) do
    instance_double(Bronze::Collections::Adapter, query: query)
  end
  let(:query) do
    instance_double(
      Bronze::Collections::Query,
      count:    3,
      each:     [].each,
      matching: subquery
    )
  end
  let(:subquery) { instance_double(Bronze::Collections::Query) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:adapter)
    end
  end

  describe '#adapter' do
    include_examples 'should have reader', :adapter, -> { adapter }
  end

  describe '#count' do
    it { expect(collection).to respond_to(:count).with(0).arguments }

    it 'should delegate to the query' do
      collection.count

      expect(query).to have_received(:count).with(no_args)
    end

    it { expect(collection.count).to be query.count }
  end

  describe '#each' do
    it { expect(collection).to respond_to(:each).with(0).arguments }

    it 'should delegate to the query' do
      collection.each

      expect(query).to have_received(:each).with(no_args)
    end

    it { expect(collection.each).to be query.each }
  end

  describe '#matching' do
    let(:selector) { { publisher: 'Amazing Stories' } }

    it { expect(collection).to respond_to(:matching).with(1).argument }

    it { expect(collection).to alias_method(:matching).as(:where) }

    it 'should delegate to the query' do
      collection.matching(selector)

      expect(query).to have_received(:matching).with(selector)
    end

    it { expect(collection.matching(selector)).to be subquery }
  end

  describe '#name' do
    include_examples 'should have reader',
      :name,
      -> { be == definition }

    context 'when the definition is a symbol' do
      let(:definition) { :periodicals }

      it { expect(collection.name).to be == 'periodicals' }
    end

    context 'when the definition is a Module' do
      let(:definition) { Spec::ArchivedPeriodical }

      example_class 'Spec::ArchivedPeriodical'

      it { expect(collection.name).to be == 'spec__archived_periodicals' }
    end

    context 'when the definition is a Module that defines ::collection_name' do
      let(:definition) { Spec::TranslatedBook }

      example_class 'Spec::TranslatedBook' do |klass|
        klass.singleton_class.send(:define_method, :collection_name) do
          'translated_books'
        end
      end

      it { expect(collection.name).to be == 'translated_books' }
    end
  end

  describe '#query' do
    it { expect(collection).to respond_to(:query).with(0).arguments }

    it { expect(collection).to alias_method(:query).as(:all) }

    it 'should delegate to the adapter' do
      collection.query

      expect(adapter).to have_received(:query).with(collection.name)
    end

    it { expect(collection.query).to be query }
  end
end
