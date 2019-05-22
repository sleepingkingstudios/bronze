# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/transforms/entities/normalize_transform'
require 'bronze/transforms/identity_transform'

require 'support/entities/examples/basic_book'
require 'support/examples/collections'

module Spec::Support::Examples::Collections
  module AdapterExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the data has many collections' do
      let(:raw_data) do
        super().merge(
          'authors'    => [],
          'magazines'  => [],
          'publishers' => []
        )
      end
    end

    shared_context 'when the data has many items' do
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
    end

    shared_context 'with an attributes transform' do
      let(:transform) do
        instance_double(
          Bronze::Transform,
          denormalize: nil,
          normalize:   nil
        )
      end

      before(:example) do
        allow(transform).to receive(:denormalize) do |hsh|
          map_keys(hsh, &:capitalize)
        end
      end

      def map_keys(hsh)
        Hash[hsh.map { |key, value| [yield(key), value] }]
      end
    end

    shared_context 'with an entity transform' do
      let(:entity_class) { Spec::BasicBook }
      let(:transform) do
        Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
      end
    end

    shared_examples 'should validate the primary key' do
      describe 'with a non-matching primary key' do
        let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::NOT_FOUND,
            params: { selector: { primary_key => primary_key_value } }
          }
        end

        it 'should not change the data' do
          expect { call_method }
            .not_to(
              change { adapter.query(collection_name: collection_name).to_a }
            )
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a non-unique primary key' do
        let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }
        let(:raw_data) do
          data = super()

          data['books'] << {
            'uuid'   => primary_key_value,
            'title'  => 'Brave New World',
            'author' => 'Aldous Huxley',
            'genre'  => 'Science Fiction'
          }

          data
        end
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::NOT_UNIQUE,
            params: { selector: { primary_key => primary_key_value } }
          }
        end

        it 'should not change the data' do
          expect { call_method }
            .not_to(
              change { adapter.query(collection_name: collection_name).to_a }
            )
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end

    shared_examples 'should implement the Adapter interface' do
      describe '#collection_name_for' do
        it 'should define the method' do
          expect(adapter).to respond_to(:collection_name_for).with(1).argument
        end
      end

      describe '#collection_name' do
        it 'should define the method' do
          expect(adapter).to respond_to(:collection_names).with(0).arguments
        end
      end

      describe '#delete_matching' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:delete_matching)
            .with(0).arguments
            .and_keywords(:collection_name, :selector)
        end
      end

      describe '#delete_one' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:delete_one)
            .with(0).arguments
            .and_keywords(:collection_name, :primary_key, :primary_key_value)
        end
      end

      describe '#find_matching' do
        let(:keywords) do
          %i[collection_name limit offset order selector transform]
        end

        it 'should define the method' do
          expect(adapter)
            .to respond_to(:find_matching)
            .with(0).arguments
            .and_keywords(*keywords)
        end
      end

      describe '#find_one' do
        let(:keywords) do
          %i[collection_name primary_key primary_key_value transform]
        end

        it 'should define the method' do
          expect(adapter)
            .to respond_to(:find_one)
            .with(0).arguments
            .and_keywords(*keywords)
        end
      end

      describe '#insert_one' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:insert_one)
            .with(0).arguments
            .and_keywords(:collection_name, :data)
        end
      end

      describe '#null_query' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:null_query)
            .with(0).arguments
            .and_keywords(:collection_name, :transform)
        end
      end

      describe '#query' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:query)
            .with(0).arguments
            .and_keywords(:collection_name, :transform)
        end
      end

      describe '#update_matching' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:update_matching)
            .with(0).arguments
            .and_keywords(:collection_name, :data, :selector)
        end
      end

      describe '#update_one' do
        let(:expected_keywords) do
          %i[collection_name data primary_key primary_key_value]
        end

        it 'should define the method' do
          expect(adapter)
            .to respond_to(:update_one)
            .with(0).arguments
            .and_keywords(*expected_keywords)
        end
      end
    end

    shared_examples 'should implement the Adapter methods' do
      let(:collection_name) { 'books' }

      def find_by_uuid(uuid)
        adapter
          .query(collection_name: collection_name)
          .matching(uuid: uuid)
          .to_a
          .first
      end

      describe '#collection_name_for' do
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
        it 'should return the collection names' do
          expect(adapter.collection_names).to contain_exactly(*raw_data.keys)
        end

        wrap_context 'when the data has many collections' do
          it { expect(adapter.collection_names).to be == raw_data.keys.sort }
        end
      end

      describe '#delete_matching' do
        shared_examples 'should delete the matching items' do
          it 'should delete each matching item' do
            call_method

            affected_items.each do |affected_item|
              actual = find_by_uuid(affected_item['uuid'])

              expect(actual).to be nil
            end
          end

          it 'should not delete the non-matching items' do
            call_method

            unaffected_items.each do |unaffected_item|
              actual = find_by_uuid(unaffected_item['uuid'])

              expect(actual).to be == unaffected_item
            end
          end

          it 'should return a passing result' do
            expect(result).to be_a_passing_result.with_value(affected_items)
          end
        end

        let(:selector) { {} }
        let(:affected_items) do
          raw_data['books']
        end
        let(:unaffected_items) do
          raw_data['books'] - affected_items
        end
        let(:result) { call_method }

        def call_method
          adapter.delete_matching(
            collection_name: collection_name,
            selector:        selector
          )
        end

        describe 'with a selector that does not match any items' do
          let(:selector)       { { genre: 'Noir' } }
          let(:affected_items) { [] }

          include_examples 'should delete the matching items'
        end

        wrap_context 'when the data has many items' do
          describe 'with an empty selector' do
            let(:selector) { {} }

            include_examples 'should delete the matching items'
          end

          describe 'with a selector that does not match any items' do
            let(:selector)       { { genre: 'Noir' } }
            let(:affected_items) { [] }

            include_examples 'should delete the matching items'
          end

          describe 'with a selector that matches one item' do
            let(:selector) { { title: 'Journey to the Center of the Earth' } }
            let(:affected_items) do
              super().select do |book|
                book['title'] == 'Journey to the Center of the Earth'
              end
            end

            include_examples 'should delete the matching items'
          end

          describe 'with a selector that matches some items' do
            let(:selector) { { author: 'H. G. Wells' } }
            let(:affected_items) do
              super().select do |book|
                book['author'] == 'H. G. Wells'
              end
            end

            include_examples 'should delete the matching items'
          end

          describe 'with a selector that matches all items' do
            let(:selector) { { genre: 'Science Fiction' } }

            include_examples 'should delete the matching items'
          end
        end
      end

      describe '#delete_one' do
        let(:primary_key)       { :uuid }
        let(:primary_key_value) { nil }
        let(:result)            { call_method }

        def call_method
          adapter.delete_one(
            collection_name:   collection_name,
            primary_key:       primary_key,
            primary_key_value: primary_key_value
          )
        end

        describe 'with a non-matching primary key' do
          let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
          let(:expected_error) do
            {
              type:   Bronze::Collections::Errors::NOT_FOUND,
              params: { selector: { primary_key => primary_key_value } }
            }
          end

          it 'should not change the data' do
            expect { call_method }
              .not_to(
                change { adapter.query(collection_name: collection_name).to_a }
              )
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end

        wrap_context 'when the data has many items' do
          include_examples 'should validate the primary key'

          describe 'with a matching primary key' do
            let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }
            let!(:expected_item)    { find_by_uuid(primary_key_value) }

            it 'should return a passing result' do
              expect(result).to be_a_passing_result.with_value(expected_item)
            end

            it 'should change the collection count' do
              expect { call_method }
                .to change(
                  adapter.query(collection_name: collection_name), :count
                )
                .by(-1)
            end

            it 'should delete the item' do
              call_method

              expect(find_by_uuid primary_key_value).to be nil
            end
          end
        end
      end

      describe '#find_matching' do
        shared_examples 'should delegate to the query' do
          # rubocop:disable RSpec/ExampleLength
          it 'should delegate to the query', :aggregate_failures do
            call_method

            expect(query).to have_received(:matching).with(selector)

            if order
              expect(query).to have_received(:order).with(*Array(order))
            else
              expect(query).not_to have_received(:order)
            end

            if limit
              expect(query).to have_received(:limit).with(limit)
            else
              expect(query).not_to have_received(:limit)
            end

            if offset
              expect(query).to have_received(:offset).with(offset)
            else
              expect(query).not_to have_received(:offset)
            end
          end
          # rubocop:enable RSpec/ExampleLength

          it 'should return a passing result' do
            expect(result).to be_a_passing_result.with_value(matching_items)
          end
        end

        shared_examples 'should find the matching items' do
          include_examples 'should delegate to the query'

          describe 'with limit: Integer' do
            let(:limit) { 4 }

            include_examples 'should delegate to the query'
          end

          describe 'with offset: Integer' do
            let(:offset) { 2 }

            include_examples 'should delegate to the query'
          end

          describe 'with order: String' do
            let(:order) { 'title' }

            include_examples 'should delegate to the query'
          end

          describe 'with order: Symbol' do
            let(:order) { :title }

            include_examples 'should delegate to the query'
          end

          describe 'with order: Hash' do
            let(:order) { { author: :asc, title: :desc } }

            include_examples 'should delegate to the query'
          end

          describe 'with order: Array' do
            let(:order) { [:author, { title: :desc }] }

            include_examples 'should delegate to the query'
          end

          describe 'with multiple options' do
            let(:limit)  { 4 }
            let(:offset) { 2 }
            let(:order)  { :title }

            include_examples 'should delegate to the query'
          end
        end

        let(:selector)       { {} }
        let(:limit)          { nil }
        let(:offset)         { nil }
        let(:order)          { nil }
        let(:transform)      { nil }
        let(:matching_items) { raw_data[collection_name] }
        let(:options) do
          {
            limit:     limit,
            offset:    offset,
            order:     order,
            transform: transform
          }
        end
        let(:query) do
          instance_double(
            query_class,
            limit:     nil,
            matching:  nil,
            offset:    nil,
            order:     nil,
            to_a:      nil,
            transform: transform
          )
        end
        let(:result) { call_method }

        def call_method
          adapter.find_matching(
            collection_name: collection_name,
            selector:        selector,
            transform:       transform,
            **options
          )
        end

        before(:example) do
          allow(adapter)
            .to receive(:query)
            .with(
              collection_name: collection_name,
              transform:       transform
            )
            .and_return(query)

          %i[matching limit offset order].each do |method_name|
            allow(query).to receive(method_name).and_return(query)
          end

          allow(query).to receive(:to_a).and_return(matching_items)
        end

        describe 'with an empty selector' do
          let(:selector) { {} }

          include_examples 'should find the matching items'
        end

        describe 'with a selector that does not match any items' do
          let(:selector)       { { genre: 'Noir' } }
          let(:matching_items) { [] }

          include_examples 'should find the matching items'
        end

        describe 'with transform: an attributes transform' do
          include_context 'with an attributes transform'

          describe 'with an empty selector' do
            let(:selector) { {} }

            include_examples 'should find the matching items'
          end

          describe 'with a selector that does not match any items' do
            let(:selector)       { { genre: 'Noir' } }
            let(:matching_items) { [] }

            include_examples 'should find the matching items'
          end
        end

        describe 'with transform: an entity transform' do
          include_context 'with an entity transform'

          describe 'with an empty selector' do
            let(:selector) { {} }

            include_examples 'should find the matching items'
          end

          describe 'with a selector that does not match any items' do
            let(:selector)       { { genre: 'Noir' } }
            let(:matching_items) { [] }

            include_examples 'should find the matching items'
          end
        end

        wrap_context 'when the data has many items' do
          describe 'with an empty selector' do
            let(:selector) { {} }

            include_examples 'should find the matching items'
          end

          describe 'with a selector that does not match any items' do
            let(:selector)       { { genre: 'Noir' } }
            let(:matching_items) { [] }

            include_examples 'should find the matching items'
          end

          describe 'with a selector that matches one item' do
            let(:selector) { { title: 'Journey to the Center of the Earth' } }
            let(:matching_items) do
              super().select do |book|
                book['title'] == 'Journey to the Center of the Earth'
              end
            end

            include_examples 'should find the matching items'
          end

          describe 'with a selector that matches some items' do
            let(:selector) { { author: 'H. G. Wells' } }
            let(:matching_items) do
              super().select do |book|
                book['author'] == 'H. G. Wells'
              end
            end

            include_examples 'should find the matching items'
          end

          describe 'with a selector that matches all items' do
            let(:selector) { { genre: 'Science Fiction' } }

            include_examples 'should find the matching items'
          end

          describe 'with transform: an attributes transform' do
            include_context 'with an attributes transform'

            describe 'with an empty selector' do
              let(:selector) { {} }

              include_examples 'should find the matching items'
            end

            describe 'with a selector that does not match any items' do
              let(:selector)       { { genre: 'Noir' } }
              let(:matching_items) { [] }

              include_examples 'should find the matching items'
            end

            describe 'with a selector that matches one item' do
              let(:selector) { { title: 'Journey to the Center of the Earth' } }
              let(:matching_items) do
                super().select do |book|
                  book['title'] == 'Journey to the Center of the Earth'
                end
              end

              include_examples 'should find the matching items'
            end

            describe 'with a selector that matches some items' do
              let(:selector) { { author: 'H. G. Wells' } }
              let(:matching_items) do
                super().select do |book|
                  book['author'] == 'H. G. Wells'
                end
              end

              include_examples 'should find the matching items'
            end

            describe 'with a selector that matches all items' do
              let(:selector) { { genre: 'Science Fiction' } }

              include_examples 'should find the matching items'
            end
          end

          describe 'with transform: an entity transform' do
            include_context 'with an entity transform'

            describe 'with an empty selector' do
              let(:selector) { {} }

              include_examples 'should find the matching items'
            end

            describe 'with a selector that does not match any items' do
              let(:selector)       { { genre: 'Noir' } }
              let(:matching_items) { [] }

              include_examples 'should find the matching items'
            end

            describe 'with a selector that matches one item' do
              let(:selector) { { title: 'Journey to the Center of the Earth' } }
              let(:matching_items) do
                super().select do |book|
                  book['title'] == 'Journey to the Center of the Earth'
                end
              end

              include_examples 'should find the matching items'
            end

            describe 'with a selector that matches some items' do
              let(:selector) { { author: 'H. G. Wells' } }
              let(:matching_items) do
                super().select do |book|
                  book['author'] == 'H. G. Wells'
                end
              end

              include_examples 'should find the matching items'
            end

            describe 'with a selector that matches all items' do
              let(:selector) { { genre: 'Science Fiction' } }

              include_examples 'should find the matching items'
            end
          end
        end
      end

      describe '#find_one' do
        let(:primary_key)       { :uuid }
        let(:primary_key_value) { nil }
        let(:transform)         { nil }
        let(:result)            { call_method }

        def call_method
          adapter.find_one(
            collection_name:   collection_name,
            primary_key:       primary_key,
            primary_key_value: primary_key_value,
            transform:         transform
          )
        end

        def change_collection_values
          change { adapter.query(collection_name: collection_name).to_a }
        end

        describe 'with a non-matching primary key' do
          let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
          let(:expected_error) do
            {
              type:   Bronze::Collections::Errors::NOT_FOUND,
              params: { selector: { primary_key => primary_key_value } }
            }
          end

          it 'should not change the data' do
            expect { call_method }
              .not_to(change_collection_values)
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end

        describe 'with transform: an attributes transform' do
          include_context 'with an attributes transform'

          describe 'with a non-matching primary key' do
            let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
            let(:expected_error) do
              {
                type:   Bronze::Collections::Errors::NOT_FOUND,
                params: { selector: { primary_key => primary_key_value } }
              }
            end

            it 'should not change the data' do
              expect { call_method }
                .not_to(change_collection_values)
            end

            it 'should return a failing result' do
              expect(call_method)
                .to be_a_failing_result
                .with_errors(expected_error)
            end
          end
        end

        describe 'with transform: an entity transform' do
          include_context 'with an entity transform'

          describe 'with a non-matching primary key' do
            let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
            let(:expected_error) do
              {
                type:   Bronze::Collections::Errors::NOT_FOUND,
                params: { selector: { primary_key => primary_key_value } }
              }
            end

            it 'should not change the data' do
              expect { call_method }
                .not_to(change_collection_values)
            end

            it 'should return a failing result' do
              expect(call_method)
                .to be_a_failing_result
                .with_errors(expected_error)
            end
          end
        end

        wrap_context 'when the data has many items' do
          include_examples 'should validate the primary key'

          describe 'with a matching primary key' do
            let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }
            let(:expected_item) do
              raw_data['books'].find do |book|
                book['uuid'] == primary_key_value
              end
            end

            it 'should return a passing result' do
              expect(result).to be_a_passing_result.with_value(expected_item)
            end

            it 'should return a copy of the data' do
              expect { result.value['tags'] = ['time travel'] }
                .not_to(change_collection_values)
            end
          end

          describe 'with transform: an attributes transform' do
            include_context 'with an attributes transform'

            include_examples 'should validate the primary key'

            describe 'with a matching primary key' do
              let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }
              let(:expected_item) do
                item =
                  raw_data['books']
                  .find { |book| book['uuid'] == primary_key_value }

                transform.denormalize(item)
              end

              it 'should return a passing result' do
                expect(result).to be_a_passing_result.with_value(expected_item)
              end

              it 'should return a copy of the data' do
                expect { result.value['tags'] = ['time travel'] }
                  .not_to(change_collection_values)
              end
            end
          end

          describe 'with transform: an entity transform' do
            include_context 'with an entity transform'

            include_examples 'should validate the primary key'

            describe 'with a matching primary key' do
              let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }
              let(:expected_item) do
                item =
                  raw_data['books']
                  .find { |book| book['uuid'] == primary_key_value }

                transform.denormalize(item)
              end

              it 'should return a passing result' do
                expect(result).to be_a_passing_result.with_value(expected_item)
              end

              it 'should return a copy of the data' do
                expect { result.value.title = 'The Island of Doctor Moreau' }
                  .not_to(change_collection_values)
              end
            end
          end
        end
      end

      describe '#insert_one' do
        shared_examples 'should insert the item' do
          let(:result) { call_method }
          let(:expected) do
            return super() if defined?(super())

            tools.hash.convert_keys_to_strings(data)
          end

          it 'should change the collection count' do
            expect { call_method }
              .to change(
                adapter.query(collection_name: collection_name), :count
              )
              .by(1)
          end

          it 'should insert the object into the collection' do
            expect { call_method }
              .to change(adapter.query(collection_name: collection_name), :to_a)
              .to include(expected)
          end

          it { expect(result).to be_a_passing_result.with_value(expected) }
        end

        def call_method
          adapter.insert_one(
            collection_name: collection_name,
            data:            data
          )
        end

        describe 'with the name of a non-existent collection' do
          let(:collection_name) { 'magazines' }

          describe 'with a data object with String keys' do
            let(:data) do
              {
                'title'  => 'Roswell Gazette',
                'volume' => 111
              }
            end

            include_examples 'should insert the item'

            it 'should create the collection' do
              expect { call_method }
                .to change(adapter, :collection_names)
                .to include collection_name
            end
          end

          describe 'with a data object with Symbol keys' do
            let(:data) do
              {
                title:  'Roswell Gazette',
                volume: 111
              }
            end

            include_examples 'should insert the item'

            it 'should create the collection' do
              expect { call_method }
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
                'uuid'   => 'ea550526-8743-4683-a58b-99bf2aa207f5',
                'title'  => 'The Island of Dr. Moreau',
                'author' => 'H. G. Wells',
                'genre'  => 'Science Fiction'
              }
            end

            include_examples 'should insert the item'

            it 'should not change the collections' do
              expect { call_method }
                .not_to change(adapter, :collection_names)
            end
          end

          describe 'with a data object with Symbol keys' do
            let(:data) do
              {
                uuid:   'ea550526-8743-4683-a58b-99bf2aa207f5',
                title:  'The Island of Dr. Moreau',
                author: 'H. G. Wells',
                genre:  'Science Fiction'
              }
            end

            include_examples 'should insert the item'

            it 'should not change the collections' do
              expect { call_method }
                .not_to change(adapter, :collection_names)
            end
          end
        end
      end

      describe '#null_query' do
        let(:query) { adapter.null_query(collection_name: 'books') }

        it { expect(query).to respond_to(:count).with(0).arguments }

        it { expect(query).to respond_to(:to_a).with(0).arguments }

        it { expect(query.count).to be 0 }

        it { expect(query.to_a).to be == [] }
      end

      describe '#query' do
        let(:query) { adapter.query(collection_name: 'books') }
        let(:default_transform) do
          defined?(super()) ? super() : nil
        end

        def be_default_transform
          return default_transform if default_transform.respond_to?(:matches?)

          # :nocov:
          be(default_transform)
          # :nocov:
        end

        it { expect(query).to be_a query_class }

        it { expect(query.transform).to be_default_transform }

        describe 'with transform: value' do
          let(:transform) { Bronze::Transforms::IdentityTransform.new }
          let(:query) do
            adapter.query(collection_name: 'books', transform: transform)
          end

          it { expect(query).to be_a query_class }

          it { expect(query.transform).to be transform }
        end
      end

      describe '#update_matching' do
        shared_examples 'should update the matching items' do
          describe 'with a data hash with String keys' do
            let(:data) { { 'published' => true } }

            it 'should update each matching item' do
              call_method

              expected.each do |expected_item|
                actual = find_by_uuid(expected_item['uuid'])

                expect(actual).to be == expected_item
              end
            end

            it 'should not update the non-matching items' do
              call_method

              unaffected_items.each do |unaffected_item|
                actual = find_by_uuid(unaffected_item['uuid'])

                expect(actual).to be == unaffected_item
              end
            end

            it 'should return a result' do
              expect(result).to be_a_passing_result.with_value(expected)
            end
          end

          describe 'with a data hash with Symbol keys' do
            let(:data)   { { published: true } }
            let(:result) { call_method }

            it 'should update each matching item' do
              call_method

              expected.each do |expected_item|
                actual = find_by_uuid(expected_item['uuid'])

                expect(actual).to be == expected_item
              end
            end

            it 'should not update the non-matching items' do
              call_method

              unaffected_items.each do |unaffected_item|
                actual = find_by_uuid(unaffected_item['uuid'])

                expect(actual).to be == unaffected_item
              end
            end

            it 'should return a result' do
              expect(result).to be_a_passing_result.with_value(expected)
            end
          end
        end

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
        let(:result) { call_method }

        def call_method
          adapter.update_matching(
            collection_name: collection_name,
            data:            data,
            selector:        selector
          )
        end

        describe 'with an empty selector' do
          let(:selector) { {} }

          include_examples 'should update the matching items'
        end

        describe 'with a selector that does not match any items' do
          let(:selector)       { { genre: 'Noir' } }
          let(:affected_items) { [] }

          include_examples 'should update the matching items'
        end

        wrap_context 'when the data has many items' do
          describe 'with an empty selector' do
            let(:selector) { {} }

            include_examples 'should update the matching items'
          end

          describe 'with a selector that does not match any items' do
            let(:selector)       { { genre: 'Noir' } }
            let(:affected_items) { [] }

            include_examples 'should update the matching items'
          end

          describe 'with a selector that matches one item' do
            let(:selector) { { title: 'Journey to the Center of the Earth' } }
            let(:affected_items) do
              super().select do |book|
                book['title'] == 'Journey to the Center of the Earth'
              end
            end

            include_examples 'should update the matching items'
          end

          describe 'with a selector that matches some items' do
            let(:selector) { { author: 'H. G. Wells' } }
            let(:affected_items) do
              super().select do |book|
                book['author'] == 'H. G. Wells'
              end
            end

            include_examples 'should update the matching items'
          end

          describe 'with a selector that matches all items' do
            let(:selector) { { genre: 'Science Fiction' } }

            include_examples 'should update the matching items'
          end
        end
      end

      describe '#update_one' do
        let(:primary_key)       { :uuid }
        let(:primary_key_value) { nil }
        let(:data)              { {} }
        let(:result)            { call_method }

        def call_method
          adapter.update_one(
            collection_name:   collection_name,
            data:              data,
            primary_key:       primary_key,
            primary_key_value: primary_key_value
          )
        end

        describe 'with a non-matching primary key' do
          let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
          let(:expected_error) do
            {
              type:   Bronze::Collections::Errors::NOT_FOUND,
              params: { selector: { primary_key => primary_key_value } }
            }
          end

          it 'should not change the data' do
            expect { call_method }
              .not_to(
                change { adapter.query(collection_name: collection_name).to_a }
              )
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end

        wrap_context 'when the data has many items' do
          include_examples 'should validate the primary key'

          describe 'with a matching primary key' do
            let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }

            describe 'with a data hash with String keys' do
              let(:data) { { 'published' => true } }
              let(:expected_item) do
                raw_data['books']
                  .find { |book| book['uuid'] == primary_key_value }
                  .merge(data)
              end

              def change_collection_values
                change { adapter.query(collection_name: collection_name).to_a }
              end

              it 'should return a passing result' do
                expect(result).to be_a_passing_result.with_value(expected_item)
              end

              it 'should update the item' do
                call_method

                expect(find_by_uuid primary_key_value).to be == expected_item
              end

              it 'should return a copy of the data' do
                result = call_method

                expect { result.value['tags'] = ['time travel'] }
                  .not_to(change_collection_values)
              end
            end

            describe 'with a data hash with Symbol keys' do
              let(:data) { { published: true } }
              let(:expected_item) do
                raw_data['books']
                  .find { |book| book['uuid'] == primary_key_value }
                  .merge(tools.hash.convert_keys_to_strings(data))
              end

              def change_collection_values
                change { adapter.query(collection_name: collection_name).to_a }
              end

              it 'should return a passing result' do
                expect(result).to be_a_passing_result.with_value(expected_item)
              end

              it 'should update the item' do
                call_method

                expect(find_by_uuid primary_key_value).to be == expected_item
              end

              it 'should return a copy of the data' do
                result = call_method

                expect { result.value['tags'] = ['time travel'] }
                  .not_to(change_collection_values)
              end
            end
          end
        end
      end
    end
  end
end
