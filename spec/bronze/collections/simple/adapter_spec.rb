# frozen_string_literal: true

require 'bronze/collections/simple/adapter'

RSpec.describe Bronze::Collections::Simple::Adapter do
  subject(:adapter) { described_class.new(raw_data) }

  let(:raw_data) do
    {
      'books' => [
        {
          'title'  => 'The Time Machine',
          'author' => 'H. G. Wells'
        },
        {
          'title'  => 'War of the Worlds',
          'author' => 'H. G. Wells'
        },
        {
          'title'  => 'Journey to the Center of the Earth',
          'author' => 'Jules Verne'
        }
      ]
    }
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#collection_name_for' do
    it { expect(adapter).to respond_to(:collection_name_for).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { adapter.collection_name_for nil }.to raise_error NameError
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { adapter.collection_name_for Object.new }
          .to raise_error NameError
      end
    end

    describe 'with a Class' do
      example_class 'Spec::ExampleClass'

      it 'should format the class name' do
        expect(adapter.collection_name_for Spec::ExampleClass)
          .to be == 'spec__example_classes'
      end
    end

    describe 'with a Module' do
      example_constant 'Spec::ExampleModule' do
        Module.new
      end

      it 'should format the module name' do
        expect(adapter.collection_name_for Spec::ExampleModule)
          .to be == 'spec__example_modules'
      end
    end
  end

  describe '#collection_names' do
    include_examples 'should have reader',
      :collection_names,
      -> { contain_exactly(*raw_data.keys) }

    context 'when the data has many collections' do
      let(:raw_data) do
        super().merge(
          'authors'    => [],
          'magazines'  => [],
          'publishers' => []
        )
      end

      it { expect(adapter.collection_names).to be == raw_data.keys.sort }
    end
  end

  describe '#data' do
    include_examples 'should have reader', :data, -> { be == raw_data }
  end

  describe '#query' do
    let(:query_class) { Bronze::Collections::Simple::Query }
    let(:query)       { adapter.query('books') }

    it { expect(adapter).to respond_to(:query).with(1).argument }

    it { expect(adapter.query('books')).to be_a query_class }

    it { expect(query.send(:data)).to be == raw_data['books'] }
  end
end
