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

  describe '#insert_one' do
    it { expect(adapter).to respond_to(:insert_one).with(2).arguments }

    describe 'with a nil data object' do
      let(:collection_name) { 'books' }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_MISSING,
          params: {}
        }
      end
      let(:result) { adapter.insert_one(collection_name, nil) }

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be nil }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with an Object' do
      let(:collection_name) { 'books' }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_INVALID,
          params: {}
        }
      end
      let(:object) { Object.new }
      let(:result) { adapter.insert_one(collection_name, object) }

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be object }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with an empty data object' do
      let(:collection_name) { 'books' }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_EMPTY,
          params: {}
        }
      end
      let(:data)   { {} }
      let(:result) { adapter.insert_one(collection_name, data) }

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be data }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with the name of a non-existent collection' do
      let(:collection_name) { 'magazines' }

      describe 'with a data object with String keys' do
        let(:magazine) do
          {
            'title'  => 'Roswell Gazette',
            'volume' => 111
          }
        end
        let(:result) { adapter.insert_one(collection_name, magazine) }

        it { expect(result).to be_a Array }

        it { expect(result.size).to be 3 }

        it { expect(result[0]).to be true }

        it { expect(result[1]).to be == magazine }

        it { expect(result[2]).to be == [] }

        it 'should create the collection' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change(adapter, :collection_names)
            .to include collection_name
        end

        it 'should change the collection count' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change { raw_data.fetch(collection_name, []).count }
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change { raw_data[collection_name] }
            .to include(magazine)
        end
      end

      describe 'with a data object with String keys' do
        let(:magazine) do
          {
            title:  'Roswell Gazette',
            volume: 111
          }
        end
        let(:expected) do
          {
            'title'  => 'Roswell Gazette',
            'volume' => 111
          }
        end
        let(:result) { adapter.insert_one(collection_name, magazine) }

        it { expect(result).to be_a Array }

        it { expect(result.size).to be 3 }

        it { expect(result[0]).to be true }

        it { expect(result[1]).to be == expected }

        it { expect(result[2]).to be == [] }

        it 'should create the collection' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change(adapter, :collection_names)
            .to include collection_name
        end

        it 'should change the collection count' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change { raw_data.fetch(collection_name, []).count }
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change { raw_data[collection_name] }
            .to include(expected)
        end
      end
    end

    describe 'with the name of an existing collection' do
      let(:collection_name) { 'books' }

      describe 'with a data object with String keys' do
        let(:book) do
          {
            'title'  => 'The Island of Dr. Moreau',
            'author' => 'H. G. Wells'
          }
        end
        let(:result) { adapter.insert_one(collection_name, book) }

        it { expect(result).to be_a Array }

        it { expect(result.size).to be 3 }

        it { expect(result[0]).to be true }

        it { expect(result[1]).to be == book }

        it { expect(result[2]).to be == [] }

        it 'should not change the collections' do
          expect { adapter.insert_one(collection_name, book) }
            .not_to change(adapter, :collection_names)
        end

        it 'should change the collection count' do
          expect { adapter.insert_one(collection_name, book) }
            .to change(raw_data[collection_name], :count)
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, book) }
            .to change { raw_data[collection_name] }
            .to include(book)
        end
      end

      describe 'with a data object with Symbol keys' do
        let(:book) do
          {
            title:  'The Island of Dr. Moreau',
            author: 'H. G. Wells'
          }
        end
        let(:expected) do
          {
            'title'  => 'The Island of Dr. Moreau',
            'author' => 'H. G. Wells'
          }
        end
        let(:result) { adapter.insert_one(collection_name, book) }

        it { expect(result).to be_a Array }

        it { expect(result.size).to be 3 }

        it { expect(result[0]).to be true }

        it { expect(result[1]).to be == expected }

        it { expect(result[2]).to be == [] }

        it 'should not change the collections' do
          expect { adapter.insert_one(collection_name, book) }
            .not_to change(adapter, :collection_names)
        end

        it 'should change the collection count' do
          expect { adapter.insert_one(collection_name, book) }
            .to change(raw_data[collection_name], :count)
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, book) }
            .to change { raw_data[collection_name] }
            .to include(expected)
        end
      end
    end
  end

  describe '#query' do
    let(:query_class) { Bronze::Collections::Simple::Query }
    let(:query)       { adapter.query('books') }

    it { expect(adapter).to respond_to(:query).with(1).argument }

    it { expect(adapter.query('books')).to be_a query_class }

    it { expect(query.send(:data)).to be == raw_data['books'] }
  end
end
