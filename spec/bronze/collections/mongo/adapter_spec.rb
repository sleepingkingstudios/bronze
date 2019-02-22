# frozen_string_literal: true

require 'bronze/collections/mongo/adapter'

RSpec.describe Bronze::Collections::Mongo::Adapter do
  subject(:adapter) do
    described_class.new(client)
  end

  let(:client) { Spec.mongo_client }
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

  # rubocop:disable RSpec/BeforeAfterAll
  before(:context) do
    Spec.mongo_client[:books].delete_many

    Spec.mongo_client[:magazines].drop
  end
  # rubocop:enable RSpec/BeforeAfterAll

  before(:example) do
    # Hack to handle MongoDB automatically adding IDs.
    raw_data['books'].each { |data| data['_id'] = BSON::ObjectId.new }

    client['books'].insert_many(raw_data['books'])
  end

  after(:example) { client['books'].delete_many }

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#client' do
    include_examples 'should have private reader',
      :client,
      -> { client }
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
    let(:expected) { Spec.mongo_client.database.collection_names }

    include_examples 'should have reader',
      :collection_names,
      -> { contain_exactly(*expected) }
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

      it 'should return a result' do
        expect(result)
          .to be_a_passing_result
          .with_value(count: affected_items.count)
      end
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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
    shared_examples 'should insert the item' do
      let(:result) { adapter.insert_one(collection_name, data) }
      let(:expected) do
        {
          count: 1,
          data:  tools.hash.convert_keys_to_strings(data)
        }
      end

      it 'should change the collection count' do
        expect { adapter.insert_one(collection_name, data) }
          .to change(adapter.query(collection_name), :count)
          .by(1)
      end

      it 'should insert the object into the collection' do
        expect { adapter.insert_one(collection_name, data) }
          .to change(adapter.query(collection_name), :to_a)
          .to include(expected[:data])
      end

      it { expect(result).to be_a_passing_result.with_value(expected) }
    end

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

      it 'should not change the data' do
        expect { adapter.insert_one(collection_name, nil) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should not change the data' do
        expect { adapter.insert_one(collection_name, object) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should not change the data' do
        expect { adapter.insert_one(collection_name, data) }
          .not_to change(adapter.query(collection_name), :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
    end

    describe 'with the name of a non-existent collection' do
      let(:collection_name) { 'magazines' }

      after(:example) { Spec.mongo_client[:magazines].drop }

      describe 'with a data object with String keys' do
        let(:data) do
          {
            '_id'    => BSON::ObjectId.new,
            'title'  => 'Roswell Gazette',
            'volume' => 111
          }
        end

        include_examples 'should insert the item'

        it 'should create the collection' do
          expect { adapter.insert_one(collection_name, data) }
            .to change(adapter, :collection_names)
            .to include collection_name
        end
      end

      describe 'with a data object with String keys' do
        let(:data) do
          {
            _id:    BSON::ObjectId.new,
            title:  'Roswell Gazette',
            volume: 111
          }
        end

        include_examples 'should insert the item'

        it 'should create the collection' do
          expect { adapter.insert_one(collection_name, data) }
            .to change(adapter, :collection_names)
            .to include collection_name
        end
      end
    end

    describe 'with the name of an existing collection' do
      let(:collection_name) { 'books' }

      describe 'with a data object with String keys' do
        let(:data) do
          {
            '_id'    => BSON::ObjectId.new,
            'uuid'   => 'ea550526-8743-4683-a58b-99bf2aa207f5',
            'title'  => 'The Island of Dr. Moreau',
            'author' => 'H. G. Wells',
            'genre'  => 'Science Fiction'
          }
        end

        include_examples 'should insert the item'

        it 'should not change the collections' do
          expect { adapter.insert_one(collection_name, data) }
            .not_to change(adapter, :collection_names)
        end
      end

      describe 'with a data object with Symbol keys' do
        let(:data) do
          {
            _id:    BSON::ObjectId.new,
            uuid:   'ea550526-8743-4683-a58b-99bf2aa207f5',
            title:  'The Island of Dr. Moreau',
            author: 'H. G. Wells',
            genre:  'Science Fiction'
          }
        end

        include_examples 'should insert the item'

        it 'should not change the collections' do
          expect { adapter.insert_one(collection_name, data) }
            .not_to change(adapter, :collection_names)
        end
      end
    end
  end

  describe '#query' do
    let(:query_class) { Bronze::Collections::Mongo::Query }
    let(:query)       { adapter.query('books') }

    it { expect(adapter).to respond_to(:query).with(1).argument }

    it { expect(adapter.query('books')).to be_a query_class }

    it { expect(query.send(:collection)).to be_a Mongo::Collection }

    it { expect(query.send(:collection).name).to be == 'books' }
  end

  describe '#update_matching' do
    shared_examples 'should update the items' do
      let(:result) { adapter.update_matching(collection_name, selector, data) }

      def find_book(uuid)
        adapter.query(collection_name).matching(uuid: uuid).to_a.first
      end

      # rubocop:disable RSpec/ExampleLength
      it 'should update each matching item' do
        adapter.update_matching(collection_name, selector, data)

        converted =
          data.is_a?(Hash) ? tools.hash.convert_keys_to_strings(data) : {}

        affected_items.each do |expected_item|
          actual = find_book(expected_item['uuid'])

          expect(actual).to be == expected_item.merge(converted)
        end
      end
      # rubocop:enable RSpec/ExampleLength

      it 'should not update the non-matching items' do
        adapter.update_matching(collection_name, selector, data)

        unaffected_items.each do |unaffected_item|
          actual = find_book(unaffected_item['uuid'])

          expect(actual).to be == unaffected_item
        end
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(expected)
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
      { count: affected_items.size }
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
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

      it 'should return a result' do
        expect(result).to be_a_failing_result.with_errors(expected_error)
      end
    end

    describe 'with an empty selector' do
      let(:selector) { {} }

      describe 'with a data hash with String keys' do
        let(:data) { { 'published' => true } }

        include_examples 'should update the items'
      end

      describe 'with a data hash with Symbol keys' do
        let(:data) { { published: true } }

        include_examples 'should update the items'
      end
    end

    describe 'with a selector that does not match any items' do
      let(:selector)       { { genre: 'Noir' } }
      let(:affected_items) { [] }

      describe 'with a data hash with String keys' do
        let(:data) { { 'published' => true } }

        include_examples 'should update the items'
      end

      describe 'with a data hash with Symbol keys' do
        let(:data) { { published: true } }

        include_examples 'should update the items'
      end
    end

    describe 'with a selector that matches one item' do
      let(:selector) { { title: 'Journey to the Center of the Earth' } }
      let(:affected_items) do
        super().select do |book|
          book['title'] == 'Journey to the Center of the Earth'
        end
      end

      describe 'with a data hash with String keys' do
        let(:data) { { 'published' => true } }

        include_examples 'should update the items'
      end

      describe 'with a data hash with Symbol keys' do
        let(:data) { { published: true } }

        include_examples 'should update the items'
      end
    end

    describe 'with a selector that matches some items' do
      let(:selector) { { author: 'H. G. Wells' } }
      let(:affected_items) do
        super().select do |book|
          book['author'] == 'H. G. Wells'
        end
      end

      describe 'with a data hash with String keys' do
        let(:data) { { 'published' => true } }

        include_examples 'should update the items'
      end

      describe 'with a data hash with Symbol keys' do
        let(:data) { { published: true } }

        include_examples 'should update the items'
      end
    end

    describe 'with a selector that matches all items' do
      let(:selector) { { genre: 'Science Fiction' } }

      describe 'with a data hash with String keys' do
        let(:data) { { 'published' => true } }

        include_examples 'should update the items'
      end

      describe 'with a data hash with Symbol keys' do
        let(:data) { { published: true } }

        include_examples 'should update the items'
      end
    end
  end
end
