# frozen_string_literal: true

require 'bronze/collections/simple/adapter'

RSpec.describe Bronze::Collections::Simple::Adapter do
  subject(:adapter) do
    data = raw_data.each.with_object({}) do |(name, collection), hsh|
      hsh[name] = collection.map { |item| tools.hash.deep_dup(item) }
    end

    described_class.new(data)
  end

  let(:raw_data) do
    {
      'books' => [
        {
          'uuid'   => 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e',
          'title'  => 'The Time Machine',
          'author' => 'H. G. Wells',
          'genre'  => 'Science Fiction'
        },
        {
          'uuid'   => 'f2559333-b4e8-46b4-a9ca-a61fcd5f6a80',
          'title'  => 'War of the Worlds',
          'author' => 'H. G. Wells',
          'genre'  => 'Science Fiction'
        },
        {
          'uuid'   => '530dc317-63e9-4d6b-b3fc-47f7be70afab',
          'title'  => 'Journey to the Center of the Earth',
          'author' => 'Jules Verne',
          'genre'  => 'Science Fiction'
        }
      ]
    }
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
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

  describe '#delete_matching' do
    shared_examples 'should delete the items' do
      let(:result) { adapter.delete_matching(collection_name, selector) }

      def find_book(uuid)
        adapter.query(collection_name).matching(uuid: uuid).to_a.first
      end

      it 'should delete each matching item' do
        adapter.delete_matching(collection_name, selector)

        affected_items.each do |affected_item|
          actual = find_book(affected_item['uuid'])

          expect(actual).to be nil
        end
      end

      it 'should not delete the non-matching items' do
        adapter.delete_matching(collection_name, selector)

        unaffected_items.each do |unaffected_item|
          actual = find_book(unaffected_item['uuid'])

          expect(actual).to be == unaffected_item
        end
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be true }

      it { expect(result[1]).to be == affected_items }

      it { expect(result[2].count).to be 0 }
    end

    let(:collection_name) { 'books' }
    let(:selector)        { {} }
    let(:affected_items) do
      raw_data['books']
    end
    let(:unaffected_items) do
      raw_data['books'] - affected_items
    end

    describe 'with a nil selector' do
      let(:result) do
        adapter.delete_matching(collection_name, nil)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::SELECTOR_MISSING,
          params: {}
        }
      end

      it 'should not change the data' do
        expect { adapter.delete_matching(collection_name, nil) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with a non-hash selector' do
      let(:selector) { Object.new }
      let(:result) do
        adapter.delete_matching(collection_name, selector)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::SELECTOR_INVALID,
          params: { selector: selector }
        }
      end

      it 'should not change the data' do
        expect { adapter.delete_matching(collection_name, selector) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with an empty selector' do
      let(:selector) { {} }

      include_examples 'should delete the items'
    end

    describe 'with a selector that does not match any items' do
      let(:selector)       { { genre: 'Noir' } }
      let(:affected_items) { [] }

      include_examples 'should delete the items'
    end

    describe 'with a selector that matches one item' do
      let(:selector) { { title: 'Journey to the Center of the Earth' } }
      let(:affected_items) do
        super().select do |book|
          book['title'] == 'Journey to the Center of the Earth'
        end
      end

      include_examples 'should delete the items'
    end

    describe 'with a selector that matches some items' do
      let(:selector) { { author: 'H. G. Wells' } }
      let(:affected_items) do
        super().select do |book|
          book['author'] == 'H. G. Wells'
        end
      end

      include_examples 'should delete the items'
    end

    describe 'with a selector that matches all items' do
      let(:selector) { { genre: 'Science Fiction' } }

      include_examples 'should delete the items'
    end
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
          params: { data: object }
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
            .to change(adapter.query(collection_name), :count)
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change(adapter.query(collection_name), :to_a)
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
            .to change(adapter.query(collection_name), :count)
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, magazine) }
            .to change(adapter.query(collection_name), :to_a)
            .to include(expected)
        end
      end
    end

    describe 'with the name of an existing collection' do
      let(:collection_name) { 'books' }

      describe 'with a data object with String keys' do
        let(:book) do
          {
            'uuid'   => 'ea550526-8743-4683-a58b-99bf2aa207f5',
            'title'  => 'The Island of Dr. Moreau',
            'author' => 'H. G. Wells',
            'genre'  => 'Science Fiction'
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
            .to change(adapter.query(collection_name), :count)
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, book) }
            .to change(adapter.query(collection_name), :to_a)
            .to include(book)
        end
      end

      describe 'with a data object with Symbol keys' do
        let(:book) do
          {
            uuid:   'ea550526-8743-4683-a58b-99bf2aa207f5',
            title:  'The Island of Dr. Moreau',
            author: 'H. G. Wells',
            genre:  'Science Fiction'
          }
        end
        let(:expected) do
          {
            'uuid'   => 'ea550526-8743-4683-a58b-99bf2aa207f5',
            'title'  => 'The Island of Dr. Moreau',
            'author' => 'H. G. Wells',
            'genre'  => 'Science Fiction'
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
            .to change(adapter.query(collection_name), :count)
            .by(1)
        end

        it 'should insert the object into the collection' do
          expect { adapter.insert_one(collection_name, book) }
            .to change(adapter.query(collection_name), :to_a)
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

  describe '#update_matching' do
    shared_examples 'should update the items' do
      describe 'with a data hash with String keys' do
        let(:data) { { 'published' => true } }
        let(:result) do
          adapter.update_matching(collection_name, selector, data)
        end

        def find_book(uuid)
          adapter.query(collection_name).matching(uuid: uuid).to_a.first
        end

        it 'should update each matching item' do
          adapter.update_matching(collection_name, selector, data)

          expected.each do |expected_item|
            actual = find_book(expected_item['uuid'])

            expect(actual).to be == expected_item
          end
        end

        it 'should not update the non-matching items' do
          adapter.update_matching(collection_name, selector, data)

          unaffected_items.each do |unaffected_item|
            actual = find_book(unaffected_item['uuid'])

            expect(actual).to be == unaffected_item
          end
        end

        it { expect(result).to be_a Array }

        it { expect(result.size).to be 3 }

        it { expect(result[0]).to be true }

        it { expect(result[1]).to be == expected }

        it { expect(result[2].count).to be 0 }
      end

      describe 'with a data hash with Symbol keys' do
        let(:data) { { published: true } }
        let(:result) do
          adapter.update_matching(collection_name, selector, data)
        end

        def find_book(uuid)
          adapter.query(collection_name).matching(uuid: uuid).to_a.first
        end

        it 'should update each matching item' do
          adapter.update_matching(collection_name, selector, data)

          expected.each do |expected_item|
            actual = find_book(expected_item['uuid'])

            expect(actual).to be == expected_item
          end
        end

        it 'should not update the non-matching items' do
          adapter.update_matching(collection_name, selector, data)

          unaffected_items.each do |unaffected_item|
            actual = find_book(unaffected_item['uuid'])

            expect(actual).to be == unaffected_item
          end
        end

        it { expect(result).to be_a Array }

        it { expect(result.size).to be 3 }

        it { expect(result[0]).to be true }

        it { expect(result[1]).to be == expected }

        it { expect(result[2].count).to be 0 }
      end
    end

    let(:collection_name) { 'books' }
    let(:selector)        { {} }
    let(:data)            { {} }
    let(:affected_items) do
      raw_data['books']
    end
    let(:unaffected_items) do
      raw_data['books'] - affected_items
    end
    let(:expected) do
      affected_items.map do |book|
        book.merge(tools.hash.convert_keys_to_strings(data))
      end
    end

    describe 'with a nil selector' do
      let(:result) do
        adapter.update_matching(collection_name, nil, data)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::SELECTOR_MISSING,
          params: {}
        }
      end

      it 'should not change the data' do
        expect { adapter.update_matching(collection_name, nil, data) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with a non-hash selector' do
      let(:selector) { Object.new }
      let(:result) do
        adapter.update_matching(collection_name, selector, data)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::SELECTOR_INVALID,
          params: { selector: selector }
        }
      end

      it 'should not change the data' do
        expect { adapter.update_matching(collection_name, selector, data) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with a nil data hash' do
      let(:result) do
        adapter.update_matching(collection_name, selector, nil)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_MISSING,
          params: {}
        }
      end

      it 'should not change the data' do
        expect { adapter.update_matching(collection_name, selector, nil) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with a non-hash data object' do
      let(:data) { Object.new }
      let(:result) do
        adapter.update_matching(collection_name, selector, data)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_INVALID,
          params: { data: data }
        }
      end

      it 'should not change the data' do
        expect { adapter.update_matching(collection_name, selector, data) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with an empty data hash' do
      let(:result) do
        adapter.update_matching(collection_name, selector, {})
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_EMPTY,
          params: {}
        }
      end

      it 'should not change the data' do
        expect { adapter.update_matching(collection_name, selector, {}) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be false }

      it { expect(result[1]).to be == [] }

      it { expect(result[2].count).to be 1 }

      it { expect(result[2]).to include expected_error }
    end

    describe 'with an empty selector' do
      let(:selector) { {} }

      include_examples 'should update the items'
    end

    describe 'with a selector that does not match any items' do
      let(:selector)       { { genre: 'Noir' } }
      let(:affected_items) { [] }

      include_examples 'should update the items'
    end

    describe 'with a selector that matches one item' do
      let(:selector) { { title: 'Journey to the Center of the Earth' } }
      let(:affected_items) do
        super().select do |book|
          book['title'] == 'Journey to the Center of the Earth'
        end
      end

      include_examples 'should update the items'
    end

    describe 'with a selector that matches some items' do
      let(:selector) { { author: 'H. G. Wells' } }
      let(:affected_items) do
        super().select do |book|
          book['author'] == 'H. G. Wells'
        end
      end

      include_examples 'should update the items'
    end

    describe 'with a selector that matches all items' do
      let(:selector) { { genre: 'Science Fiction' } }

      include_examples 'should update the items'
    end
  end
end
