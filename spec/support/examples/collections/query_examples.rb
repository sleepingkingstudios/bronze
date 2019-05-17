# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/transforms/identity_transform'

require 'support/examples/collections'

module Spec::Support::Examples::Collections
  module QueryExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the data has many items' do
      let(:raw_data) do
        [
          {
            'title'  => 'The Moon Maid',
            'author' => 'Edgar Rice Burroughs'
          },
          {
            'title'  => 'A Princess of Mars',
            'author' => 'Edgar Rice Burroughs',
            'series' => 'Barsoom',
            'index'  => 1
          },
          {
            'title'  => 'The Gods of Mars',
            'author' => 'Edgar Rice Burroughs',
            'series' => 'Barsoom',
            'index'  => 2
          },
          {
            'title'  => 'The Warlord of Mars',
            'author' => 'Edgar Rice Burroughs',
            'series' => 'Barsoom',
            'index'  => 3
          },
          {
            'title'  => 'Beyond The Farthest Star',
            'author' => 'Edgar Rice Burroughs'
          },
          {
            'title'  => "At The Earth's Core",
            'author' => 'Edgar Rice Burroughs',
            'series' => 'Pellucidar',
            'index'  => 1
          },
          {
            'title'  => 'Pellucidar',
            'author' => 'Edgar Rice Burroughs',
            'series' => 'Pellucidar',
            'index'  => 2
          }
        ]
      end
    end

    shared_context 'when the query has a non-matching filter' do
      let(:query)         { super().matching('author' => 'C. S. Lewis') }
      let(:filtered_data) { [] }
      let(:queried_data)  { filtered_data }
      let(:expected_data) { queried_data }
    end

    shared_context 'when the query has a matching filter' do
      let(:query) { super().matching('series' => 'Barsoom') }
      let(:matching_data) do
        raw_data.select { |item| item['series'] == 'Barsoom' }
      end
      let(:queried_data) do
        raw_data.select { |item| item['series'] == 'Barsoom' }
      end
    end

    shared_context 'when the query has a simple ordering' do
      let(:query)         { super().order(:title) }
      let(:matching_data) { raw_data }
      let(:ordered_data)  { matching_data.sort_by { |item| item['title'] } }
      let(:queried_data)  { raw_data.sort_by { |item| item['title'] } }
    end

    shared_context 'when the query has a complex ordering' do
      let(:sort_nils_before_values) do
        # The default behavior is to sort nil values after non-nil. This is
        # the expected behavior for Postgres, as well as the built-in Simple
        # collection.
        defined?(super()) ? super() : false
      end
      let(:query)         { super().order(:series, title: :desc) }
      let(:matching_data) { raw_data }
      let(:ordered_data) do
        Spec::Support::Sorting
          .new(sort_nils_before_values: sort_nils_before_values)
          .sort_hashes(matching_data, 'series' => :asc, 'title' => :desc)
      end
      let(:queried_data) do
        Spec::Support::Sorting
          .new(sort_nils_before_values: sort_nils_before_values)
          .sort_hashes(raw_data, 'series' => :asc, 'title' => :desc)
      end
    end

    shared_context 'when the query has an ordering and a limit' do
      let(:limit)         { 4 }
      let(:offset)        { 2 }
      let(:query)         { super().order(:title).limit(4).offset(2) }
      let(:matching_data) { raw_data }
      let(:ordered_data)  { matching_data.sort_by { |item| item['title'] } }
      let(:queried_data)  { raw_data.sort_by { |item| item['title'] }[2...6] }
    end

    shared_examples 'should filter the data' do
      describe 'should filter the data' do
        let(:subquery)      { defined?(super()) ? super() : query }
        let(:limit)         { defined?(super()) ? super() : raw_data.size }
        let(:offset)        { defined?(super()) ? super() : 0 }
        let(:matching_data) { defined?(super()) ? super() : raw_data }
        let(:ordered_data)  { defined?(super()) ? super() : matching_data }
        let(:filtered_data) do
          return super() if defined?(super())

          ordered_data[offset...(offset + limit)] || []
        end

        it { expect(subquery.count).to be == filtered_data.size }

        it { expect(subquery.to_a).to be == filtered_data }
      end
    end

    shared_examples 'should implement the Query interface' do
      describe '#count' do
        it { expect(query).to respond_to(:count).with(0).arguments }
      end

      describe '#each' do
        it { expect(query).to respond_to(:each).with(0).arguments }
      end

      describe '#exists?' do
        it { expect(query).to respond_to(:exists?).with(0).arguments }
      end

      describe '#limit' do
        it { expect(query).to respond_to(:limit).with(1).argument }
      end

      describe '#matching' do
        it { expect(query).to respond_to(:matching).with(1).argument }

        it { expect(query).to alias_method(:matching).as(:where) }
      end

      describe '#none' do
        it { expect(query).to respond_to(:none).with(0).arguments }
      end

      describe '#offset' do
        it { expect(query).to respond_to(:offset).with(1).argument }

        it { expect(query).to alias_method(:offset).as(:skip) }
      end

      describe '#order' do
        it 'should define the method' do
          expect(query)
            .to respond_to(:order)
            .with(1).argument
            .and_unlimited_arguments
        end
      end

      describe '#to_a' do
        it { expect(query).to respond_to(:to_a).with(0).arguments }
      end

      describe '#transform' do
        it { expect(query).to respond_to(:transform).with(0).arguments }
      end
    end

    shared_examples 'should implement the Query methods' do
      describe '#count' do
        it { expect(query.count).to be 0 }

        wrap_context 'when the data has many items' do
          it { expect(query.count).to be raw_data.size }
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }
        end
      end

      describe '#dup' do
        let(:copied_query) { query.dup }

        it { expect(copied_query.count).to be 0 }

        it { expect(copied_query.to_a).to be == [] }

        wrap_context 'when the data has many items' do
          it { expect(copied_query.count).to be raw_data.size }

          it { expect(copied_query.to_a).to be == raw_data }
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(copied_query.count).to be queried_data.size }

          it { expect(copied_query.to_a).to be == queried_data }
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          it { expect(copied_query.count).to be queried_data.size }

          it { expect(copied_query.to_a).to be == queried_data }
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          it { expect(copied_query.count).to be queried_data.size }

          it { expect(copied_query.to_a).to be == queried_data }
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          it { expect(copied_query.count).to be queried_data.size }

          it { expect(copied_query.to_a).to be == queried_data }
        end
      end

      describe '#each' do
        it { expect(query.each).to be_a Enumerator }

        it { expect(query.each.to_a).to be == [] }

        describe 'with a block' do
          it 'should not yield control' do
            expect { |block| query.each(&block) }.not_to yield_control
          end
        end

        wrap_context 'when the data has many items' do
          it { expect(query.each).to be_a Enumerator }

          it { expect(query.each.to_a).to be == raw_data }

          describe 'with a block' do
            it 'should yield each item' do
              expect { |block| query.each(&block) }
                .to yield_successive_args(*raw_data)
            end
          end
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.each).to be_a Enumerator }

          it { expect(query.each.to_a).to be == queried_data }

          describe 'with a block' do
            it 'should yield each item' do
              expect { |block| query.each(&block) }
                .to yield_successive_args(*queried_data)
            end
          end
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          it { expect(query.each).to be_a Enumerator }

          it { expect(query.each.to_a).to be == queried_data }

          describe 'with a block' do
            it 'should yield each item' do
              expect { |block| query.each(&block) }
                .to yield_successive_args(*queried_data)
            end
          end
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          it { expect(query.each).to be_a Enumerator }

          it { expect(query.each.to_a).to be == queried_data }

          describe 'with a block' do
            it 'should yield each item' do
              expect { |block| query.each(&block) }
                .to yield_successive_args(*queried_data)
            end
          end
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          it { expect(query.each).to be_a Enumerator }

          it { expect(query.each.to_a).to be == queried_data }

          describe 'with a block' do
            it 'should yield each item' do
              expect { |block| query.each(&block) }
                .to yield_successive_args(*queried_data)
            end
          end
        end
      end

      describe '#exists?' do
        it { expect(query.exists?).to be false }

        wrap_context 'when the data has many items' do
          it { expect(query.exists?).to be true }
        end

        wrap_context 'when the query has a non-matching filter' do
          include_context 'when the data has many items'

          it { expect(query.exists?).to be false }
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.exists?).to be true }
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          it { expect(query.exists?).to be true }
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          it { expect(query.exists?).to be true }
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          it { expect(query.exists?).to be true }
        end
      end

      describe '#limit' do
        let(:limit)    { 3 }
        let(:subquery) { query.limit(limit) }

        it { expect(query.limit 3).not_to be query }

        it { expect(query.limit 3).to be_a described_class }

        describe 'with nil' do
          let(:error_message) do
            'expected limit to be a positive integer, but was nil'
          end

          it 'should raise an error' do
            expect { query.limit nil }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:object) { Object.new.freeze }
          let(:error_message) do
            "expected limit to be a positive integer, but was #{object.inspect}"
          end

          it 'should raise an error' do
            expect { query.limit object }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a negative integer' do
          let(:error_message) do
            'expected limit to be a positive integer, but was -1'
          end

          it 'should raise an error' do
            expect { query.limit(-1) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with zero' do
          let(:error_message) do
            'expected limit to be a positive integer, but was 0'
          end

          it 'should raise an error' do
            expect { query.limit(0) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with one' do
          let(:limit) { 1 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          include_examples 'should filter the data'
        end

        describe 'with a larger number' do
          let(:limit) { 3 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          include_examples 'should filter the data'
        end

        wrap_context 'when the data has many items' do
          describe 'with one' do
            let(:limit) { 1 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:limit) { 3 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:limit) { raw_data.count }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:limit) { raw_data.count + 3 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          describe 'with one' do
            let(:limit) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:limit) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:limit) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          describe 'with one' do
            let(:limit) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:limit) { 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:limit) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:limit) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          describe 'with one' do
            let(:limit) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:limit) { 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:limit) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:limit) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          describe 'with one' do
            let(:limit) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:limit) { 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:limit) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:limit) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end
      end

      describe '#matching' do
        let(:selector) { {} }
        let(:subquery) { query.matching(selector) }

        it { expect(query.matching(selector)).not_to be query }

        it { expect(query.matching(selector)).to be_a described_class }

        describe 'with nil' do
          let(:error_message) do
            'expected selector to be a Hash, but was nil'
          end

          it 'should raise an error' do
            expect { query.matching(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:object) { Object.new }
          let(:error_message) do
            "expected selector to be a Hash, but was #{object.inspect}"
          end

          it 'should raise an error' do
            expect { query.matching(object) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty selector' do
          let(:selector) { {} }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          include_examples 'should filter the data'
        end

        describe 'with a value selector' do
          let(:selector) { { 'title' => 'Savage Pellucidar' } }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          include_examples 'should filter the data'
        end

        wrap_context 'when the data has many items' do
          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'series' => 'Barsoom' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector with symbol keys' do
            let(:selector) { { series: 'Barsoom' } }
            let(:matching_data) do
              raw_data.select { |item| item['series'] == 'Barsoom' }
            end

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }
            let(:matching_data) do
              super().select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'index' => 2 } }
            let(:matching_data) do
              super().select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }
            let(:matching_data) do
              super().select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'index' => 2 } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'index' => 2 } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'series' => 'Barsoom' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }
            let(:matching_data) do
              raw_data.select { |item| item >= selector }
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end
      end

      describe '#none' do
        let(:subquery)      { query.none }
        let(:filtered_data) { [] }

        it { expect(query.none).not_to be query }

        it { expect(query.none).to be_a Bronze::Collections::Query }

        it { expect(query.count).to be 0 }

        it { expect(query.to_a).to be == [] }

        include_examples 'should filter the data'

        wrap_context 'when the data has many items' do
          it { expect(query.count).to be raw_data.size }

          it { expect(query.to_a).to be == raw_data }

          include_examples 'should filter the data'
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }

          it { expect(query.to_a).to be == queried_data }

          include_examples 'should filter the data'
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }

          it { expect(query.to_a).to be == queried_data }

          include_examples 'should filter the data'
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }

          it { expect(query.to_a).to be == queried_data }

          include_examples 'should filter the data'
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          it { expect(query.count).to be queried_data.size }

          it { expect(query.to_a).to be == queried_data }

          include_examples 'should filter the data'
        end
      end

      describe '#offset' do
        let(:offset)   { 3 }
        let(:subquery) { query.offset(offset) }

        it { expect(query.offset 3).not_to be query }

        it { expect(query.offset 3).to be_a described_class }

        describe 'with nil' do
          let(:error_message) do
            'expected offset to be an integer greater than or equal to zero, ' \
            'but was nil'
          end

          it 'should raise an error' do
            expect { query.offset nil }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:object) { Object.new.freeze }
          let(:error_message) do
            'expected offset to be an integer greater than or equal to zero, ' \
            "but was #{object.inspect}"
          end

          it 'should raise an error' do
            expect { query.offset object }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a negative integer' do
          let(:error_message) do
            'expected offset to be an integer greater than or equal to zero, ' \
            'but was -1'
          end

          it 'should raise an error' do
            expect { query.offset(-1) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with zero' do
          let(:offset) { 0 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        describe 'with one' do
          let(:offset) { 1 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        describe 'with a larger number' do
          let(:offset) { 3 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        wrap_context 'when the data has many items' do
          describe 'with zero' do
            let(:offset) { 0 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with one' do
            let(:offset) { 1 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:offset) { 3 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:offset) { raw_data.count }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:offset) { raw_data.count + 3 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          describe 'with zero' do
            let(:offset) { 0 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with one' do
            let(:offset) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:offset) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:offset) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          describe 'with zero' do
            let(:offset) { 0 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with one' do
            let(:offset) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:offset) { 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:offset) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:offset) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          describe 'with zero' do
            let(:offset) { 0 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with one' do
            let(:offset) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:offset) { 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:offset) { queried_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:offset) { queried_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          describe 'with zero' do
            let(:offset) { 0 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with one' do
            let(:offset) { 1 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with three' do
            let(:offset) { 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with the number of items' do
            let(:offset) { ordered_data.count }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with greater than the number of items' do
            let(:offset) { ordered_data.count + 3 }

            it { expect(query.count).to be queried_data.count }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end
      end

      describe '#order' do
        shared_examples 'should sort the data by one attribute' \
        do |reversed: false|
          context 'when no items have the attribute' do
            let(:attribute) { 'attributions' }

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          context 'when some items have the attribute' do
            let(:attribute) { 'series' }
            let(:items_without_attribute) do
              matching_data.select { |item| item['series'].nil? }
            end
            let(:matching_ascending) do
              matching_data
                .reject { |item| item['series'].nil? }
                .sort_by { |item| item['series'] }
            end
            let(:sorted_ascending) do
              if sort_nils_before_values
                # :nocov:
                items_without_attribute + matching_ascending
                # :nocov:
              else
                matching_ascending + items_without_attribute
              end
            end
            let(:matching_descending) do
              matching_data
                .reject { |item| item['series'].nil? }
                .sort { |u, v| v['series'] <=> u['series'] }
            end
            let(:sorted_descending) do
              if sort_nils_before_values
                # :nocov:
                matching_descending + items_without_attribute
                # :nocov:
              else
                items_without_attribute + matching_descending
              end
            end
            let(:ordered_data) do
              reversed ? sorted_descending : sorted_ascending
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          context 'when all items have the attribute' do
            let(:attribute) { 'title' }
            let(:sorted) do
              matching_data.sort_by { |item| item['title'] }
            end
            let(:ordered_data) { reversed ? sorted.reverse : sorted }

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        shared_examples 'should sort the data' do
          describe 'with a String' do
            let(:subquery) { query.order(attribute.to_s) }

            include_examples 'should sort the data by one attribute'
          end

          describe 'with a Symbol' do
            let(:subquery) { query.order(attribute.intern) }

            include_examples 'should sort the data by one attribute'
          end

          describe 'with a String => :asc' do
            let(:subquery) { query.order(attribute.to_s => :asc) }

            include_examples 'should sort the data by one attribute'
          end

          describe 'with a String => :ascending' do
            let(:subquery) { query.order(attribute.to_s => :ascending) }

            include_examples 'should sort the data by one attribute'
          end

          describe 'with a String => "asc"' do
            let(:subquery) { query.order(attribute.to_s => 'asc') }

            include_examples 'should sort the data by one attribute'
          end

          describe 'with a String => "ascending"' do
            let(:subquery) { query.order(attribute.to_s => 'asc') }

            include_examples 'should sort the data by one attribute'
          end

          describe 'with a Symbol => :desc' do
            let(:subquery) { query.order(attribute.intern => :desc) }

            include_examples 'should sort the data by one attribute',
              reversed: true
          end

          describe 'with a Symbol => :descending' do
            let(:subquery) { query.order(attribute.intern => :desc) }

            include_examples 'should sort the data by one attribute',
              reversed: true
          end

          describe 'with a Symbol => "desc"' do
            let(:subquery) { query.order(attribute.intern => 'desc') }

            include_examples 'should sort the data by one attribute',
              reversed: true
          end

          describe 'with a Symbol => "descending"' do
            let(:subquery) { query.order(attribute.intern => 'desc') }

            include_examples 'should sort the data by one attribute',
              reversed: true
          end

          describe 'with multiple valid attributes' do
            let(:subquery) { query.order(:series, :title) }
            let(:ordered_data) do
              Spec::Support::Sorting
                .new(sort_nils_before_values: sort_nils_before_values)
                .sort_hashes(matching_data, 'series' => :asc, 'title' => :asc)
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end

          describe 'with a Hash with multiple valid key-value pairs' do
            let(:subquery) { query.order(series: :asc, title: :desc) }
            let(:ordered_data) do
              Spec::Support::Sorting
                .new(sort_nils_before_values: sort_nils_before_values)
                .sort_hashes(matching_data, 'series' => :asc, 'title' => :desc)
            end

            it { expect(query.count).to be queried_data.size }

            it { expect(query.to_a).to be == queried_data }

            include_examples 'should filter the data'
          end
        end

        let(:attributes)    { %w[title] }
        let(:subquery)      { query.order(*attributes) }
        let(:queried_data)  { raw_data }
        let(:expected_data) { queried_data }
        let(:sort_nils_before_values) do
          # The default behavior is to sort nil values after non-nil. This is
          # the expected behavior for Postgres, as well as the built-in Simple
          # collection.
          defined?(super()) ? super() : false
        end

        it { expect(query.order(*attributes)).not_to be query }

        it { expect(query.order(*attributes)).to be_a described_class }

        describe 'with no arguments' do
          let(:error_message) { "ordering can't be empty" }

          it 'should raise an error' do
            expect { query.order }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with nil' do
          let(:error_message) { 'invalid ordering - nil' }

          it 'should raise an error' do
            expect { query.order(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:object) { Object.new }
          let(:error_message) do
            "invalid ordering - #{object.inspect}"
          end

          it 'should raise an error' do
            expect { query.order(object) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty Hash' do
          let(:error_message) { "ordering can't be empty" }

          it 'should raise an error' do
            expect { query.order }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a Hash with invalid key' do
          let(:object) { Object.new }
          let(:error_message) do
            "invalid ordering - #{object.inspect}: :asc"
          end

          it 'should raise an error' do
            expect { query.order(object => :asc) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a Hash with Object value' do
          let(:object) { Object.new }
          let(:error_message) do
            "invalid ordering (:title => #{object.inspect}) - sort direction " \
            'must be "ascending" (or :asc) or "descending" (or :desc)'
          end

          it 'should raise an error' do
            expect { query.order(title: object) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a Hash with invalid Symbol value' do
          let(:error_message) do
            'invalid ordering (:title => :random) - sort direction ' \
            'must be "ascending" (or :asc) or "descending" (or :desc)'
          end

          it 'should raise an error' do
            expect { query.order(title: :random) }
              .to raise_error ArgumentError, error_message
          end
        end

        include_examples 'should sort the data'

        wrap_context 'when the data has many items' do
          include_examples 'should sort the data'
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          include_examples 'should sort the data'
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          # Calling #order overwrites the previous ordering.
          let(:ordered_data) { raw_data }

          include_examples 'should sort the data'
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          # Calling #order overwrites the previous ordering.
          let(:ordered_data) { raw_data }

          include_examples 'should sort the data'
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          # Calling #order overwrites the previous ordering.
          let(:ordered_data) { raw_data }

          include_examples 'should sort the data'
        end
      end

      describe '#to_a' do
        it { expect(query.to_a).to be == [] }

        wrap_context 'when the data has many items' do
          it { expect(query.to_a).to be == raw_data }
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.to_a).to be == queried_data }
        end

        wrap_context 'when the query has a simple ordering' do
          include_context 'when the data has many items'

          it { expect(query.to_a).to be == queried_data }
        end

        wrap_context 'when the query has a complex ordering' do
          include_context 'when the data has many items'

          it { expect(query.to_a).to be == queried_data }
        end

        wrap_context 'when the query has an ordering and a limit' do
          include_context 'when the data has many items'

          it { expect(query.to_a).to be == queried_data }
        end
      end

      describe '#transform' do
        let(:default_transform) { defined?(super()) ? super() : nil }

        it { expect(query.transform).to be default_transform }

        context 'when initialized with a transform' do
          let(:transform)          { Bronze::Transforms::IdentityTransform.new }
          let(:expected_transform) { defined?(super()) ? super() : transform }

          it { expect(query.transform).to be expected_transform }
        end
      end
    end
  end
end
