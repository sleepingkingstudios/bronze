# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

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
          expect { call_operation }
            .not_to(change { adapter.query(collection_name).to_a })
        end

        it 'should return a failing result' do
          expect(call_operation)
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
          expect { call_operation }
            .not_to(change { adapter.query(collection_name).to_a })
        end

        it 'should return a failing result' do
          expect(call_operation)
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
        it { expect(adapter).to respond_to(:delete_matching).with(2).arguments }
      end

      describe '#delete_one' do
        it { expect(adapter).to respond_to(:delete_one).with(3).arguments }
      end

      describe '#find_matching' do
        it 'should define the method' do
          expect(adapter)
            .to respond_to(:find_matching)
            .with(2).arguments
            .and_keywords(:limit, :offset, :order)
        end
      end

      describe '#find_one' do
        it { expect(adapter).to respond_to(:find_one).with(3).arguments }
      end

      describe '#insert_one' do
        it { expect(adapter).to respond_to(:insert_one).with(2).arguments }
      end

      describe '#query' do
        it { expect(adapter).to respond_to(:query).with(1).argument }
      end

      describe '#update_matching' do
        it { expect(adapter).to respond_to(:update_matching).with(3).arguments }
      end

      describe '#update_one' do
        it { expect(adapter).to respond_to(:update_one).with(4).arguments }
      end
    end

    shared_examples 'should implement the Adapter methods' do
      let(:collection_name) { 'books' }

      def find_by_uuid(uuid)
        adapter.query(collection_name).matching(uuid: uuid).to_a.first
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
            adapter.delete_matching(collection_name, selector)

            affected_items.each do |affected_item|
              actual = find_by_uuid(affected_item['uuid'])

              expect(actual).to be nil
            end
          end

          it 'should not delete the non-matching items' do
            adapter.delete_matching(collection_name, selector)

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
        let(:result) { call_operation }

        def call_operation
          adapter.delete_matching(collection_name, selector)
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
        let(:result)            { call_operation }

        def call_operation
          adapter.delete_one(collection_name, primary_key, primary_key_value)
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
            expect { call_operation }
              .not_to(change { adapter.query(collection_name).to_a })
          end

          it 'should return a failing result' do
            expect(call_operation)
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
              expect { call_operation }
                .to change(adapter.query(collection_name), :count)
                .by(-1)
            end

            it 'should delete the item' do
              call_operation

              expect(find_by_uuid primary_key_value).to be nil
            end
          end
        end
      end

      describe '#find_matching' do
        shared_examples 'should delegate to the query' do
          # rubocop:disable RSpec/ExampleLength
          it 'should delegate to the query', :aggregate_failures do
            adapter.find_matching(collection_name, selector, **options)

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
        let(:options)        { { limit: limit, offset: offset, order: order } }
        let(:matching_items) { raw_data[collection_name] }
        let(:query) do
          instance_double(
            query_class,
            limit:    nil,
            matching: nil,
            offset:   nil,
            order:    nil,
            to_a:     nil
          )
        end
        let(:result) { call_operation }

        def call_operation
          adapter.find_matching(collection_name, selector, **options)
        end

        before(:example) do
          allow(adapter)
            .to receive(:query)
            .with(collection_name)
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
        end
      end

      describe '#find_one' do
        let(:primary_key)       { :uuid }
        let(:primary_key_value) { nil }
        let(:result)            { call_operation }

        def call_operation
          adapter.find_one(collection_name, primary_key, primary_key_value)
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
            expect { call_operation }
              .not_to(change { adapter.query(collection_name).to_a })
          end

          it 'should return a failing result' do
            expect(call_operation)
              .to be_a_failing_result
              .with_errors(expected_error)
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
                .not_to(change { adapter.query(collection_name).to_a })
            end
          end
        end
      end

      describe '#insert_one' do
        shared_examples 'should insert the item' do
          let(:result) { adapter.insert_one(collection_name, data) }
          let(:expected) do
            tools.hash.convert_keys_to_strings(data)
          end

          it 'should change the collection count' do
            expect { adapter.insert_one(collection_name, data) }
              .to change(adapter.query(collection_name), :count)
              .by(1)
          end

          it 'should insert the object into the collection' do
            expect { adapter.insert_one(collection_name, data) }
              .to change(adapter.query(collection_name), :to_a)
              .to include(expected)
          end

          it { expect(result).to be_a_passing_result.with_value(expected) }
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
              expect { adapter.insert_one(collection_name, data) }
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
        it { expect(adapter.query('books')).to be_a query_class }
      end

      describe '#update_matching' do
        shared_examples 'should update the matching items' do
          describe 'with a data hash with String keys' do
            let(:data) { { 'published' => true } }

            it 'should update each matching item' do
              adapter.update_matching(collection_name, selector, data)

              expected.each do |expected_item|
                actual = find_by_uuid(expected_item['uuid'])

                expect(actual).to be == expected_item
              end
            end

            it 'should not update the non-matching items' do
              adapter.update_matching(collection_name, selector, data)

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
            let(:data) { { published: true } }
            let(:result) do
              adapter.update_matching(collection_name, selector, data)
            end

            it 'should update each matching item' do
              adapter.update_matching(collection_name, selector, data)

              expected.each do |expected_item|
                actual = find_by_uuid(expected_item['uuid'])

                expect(actual).to be == expected_item
              end
            end

            it 'should not update the non-matching items' do
              adapter.update_matching(collection_name, selector, data)

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
        let(:result) { call_operation }

        def call_operation
          adapter.update_matching(collection_name, selector, data)
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
        let(:result)            { call_operation }

        def call_operation
          adapter.update_one(
            collection_name,
            primary_key,
            primary_key_value,
            data
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
            expect { call_operation }
              .not_to(change { adapter.query(collection_name).to_a })
          end

          it 'should return a failing result' do
            expect(call_operation)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end

        wrap_context 'when the data has many items' do
          include_examples 'should validate the primary key'

          describe 'with a matching primary key' do
            let(:primary_key_value) { 'ff0ea8fc-05b2-4f1f-b661-4d6e543ce86e' }

            def find_book(uuid)
              adapter.query(collection_name).matching(uuid: uuid).to_a.first
            end

            describe 'with a data hash with String keys' do
              let(:data) { { 'published' => true } }
              let(:expected_item) do
                raw_data['books']
                  .find { |book| book['uuid'] == primary_key_value }
                  .merge(data)
              end

              it 'should return a passing result' do
                expect(result).to be_a_passing_result.with_value(expected_item)
              end

              it 'should update the item' do
                call_operation

                expect(find_book primary_key_value).to be == expected_item
              end

              it 'should return a copy of the data' do
                result = call_operation

                expect { result.value['tags'] = ['time travel'] }
                  .not_to(change { adapter.query(collection_name).to_a })
              end
            end

            describe 'with a data hash with Symbol keys' do
              let(:data) { { published: true } }
              let(:expected_item) do
                raw_data['books']
                  .find { |book| book['uuid'] == primary_key_value }
                  .merge(tools.hash.convert_keys_to_strings(data))
              end

              it 'should return a passing result' do
                expect(result).to be_a_passing_result.with_value(expected_item)
              end

              it 'should update the item' do
                call_operation

                expect(find_book primary_key_value).to be == expected_item
              end

              it 'should return a copy of the data' do
                result = call_operation

                expect { result.value['tags'] = ['time travel'] }
                  .not_to(change { adapter.query(collection_name).to_a })
              end
            end
          end
        end
      end
    end
  end
end