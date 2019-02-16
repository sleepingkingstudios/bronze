# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/collection'
require 'bronze/collections/query'
require 'bronze/errors'

RSpec.describe Bronze::Collections::Collection do
  subject(:collection) do
    described_class.new(definition, adapter: adapter, **options)
  end

  let(:options)    { {} }
  let(:definition) { 'books' }
  let(:adapter) do
    instance_double(
      Bronze::Collections::Adapter,
      collection_name_for: '',
      insert_one:          [],
      query:               query,
      update_matching:     []
    )
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
        .and_keywords(:adapter, :name)
    end

    describe 'with nil' do
      let(:error_message) do
        'expected definition to be a collection name or a class, but was nil'
      end

      it 'should raise an error' do
        expect { described_class.new(nil, adapter: adapter) }
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
        expect { described_class.new(object, adapter: adapter) }
          .to raise_error ArgumentError, error_message
      end
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

  describe '#insert_one' do
    let(:data) do
      {
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:result) do
      [
        true,
        data,
        Bronze::Errors.new
      ]
    end

    it { expect(collection).to respond_to(:insert_one).with(1).argument }

    it 'should delegate to the adapter' do
      collection.insert_one(data)

      expect(adapter).to have_received(:insert_one).with(collection.name, data)
    end

    it 'should return the result from the adapter' do
      allow(adapter).to receive(:insert_one).and_return(result)

      expect(collection.insert_one(data)).to be result
    end
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

      context 'when options[:name] is set' do
        let(:options) { { name: 'magazines' } }

        it { expect(collection.name).to be == 'magazines' }
      end
    end

    context 'when the definition is a Module' do
      let(:definition) { Spec::ArchivedPeriodical }

      example_class 'Spec::ArchivedPeriodical'

      before(:example) do
        allow(adapter)
          .to receive(:collection_name_for)
          .with(definition)
          .and_return('spec__archived_periodicals')
      end

      it { expect(collection.name).to be == 'spec__archived_periodicals' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'magazines' } }

        it { expect(collection.name).to be == 'magazines' }
      end
    end

    context 'when the definition is a Module that defines ::collection_name' do
      let(:definition) { Spec::TranslatedBook }

      example_class 'Spec::TranslatedBook' do |klass|
        klass.singleton_class.send(:define_method, :collection_name) do
          'translated_books'
        end
      end

      it { expect(collection.name).to be == 'translated_books' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'books' } }

        it { expect(collection.name).to be == 'books' }
      end
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

  describe '#update_matching' do
    let(:selector) { { author: 'Luo Guanzhong' } }
    let(:data)     { { 'language' => 'Chinese' } }
    let(:expected) do
      {
        'title'    => 'Romance of the Three Kingdoms',
        'author'   => 'Luo Guanzhong',
        'language' => 'Chinese'
      }
    end
    let(:result) do
      [
        true,
        [expected],
        Bronze::Errors.new
      ]
    end

    it 'should define the method' do
      expect(collection).to respond_to(:update_matching)
        .with(1).arguments
        .with_keywords(:with)
    end

    it 'should delegate to the adapter' do
      collection.update_matching(selector, with: data)

      expect(adapter)
        .to have_received(:update_matching)
        .with(collection.name, selector, data)
    end

    it 'should return the result from the adapter' do
      allow(adapter).to receive(:update_matching).and_return(result)

      expect(collection.update_matching(selector, with: data)).to be result
    end
  end
end
