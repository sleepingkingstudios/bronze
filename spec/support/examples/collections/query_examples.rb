# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

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
      let(:expected_data) { [] }
    end

    shared_context 'when the query has a matching filter' do
      let(:query) { super().matching('series' => 'Barsoom') }
      let(:expected_data) do
        raw_data.select { |item| item['series'] == 'Barsoom' }
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
    end

    shared_examples 'should implement the Query methods' do
      describe '#count' do
        it { expect(query.count).to be 0 }

        wrap_context 'when the data has many items' do
          it { expect(query.count).to be raw_data.size }
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.count).to be expected_data.size }
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

          it { expect(copied_query.count).to be expected_data.size }

          it { expect(copied_query.to_a).to be == expected_data }
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

          it { expect(query.each.to_a).to be == expected_data }

          describe 'with a block' do
            it 'should yield each item' do
              expect { |block| query.each(&block) }
                .to yield_successive_args(*expected_data)
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
      end

      describe '#limit' do
        let(:count)    { 3 }
        let(:subquery) { query.limit(count) }

        it { expect(query.limit 3).not_to be query }

        it { expect(query.limit 3).to be_a described_class }

        describe 'with zero' do
          let(:count) { 0 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        describe 'with one' do
          let(:count) { 1 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        describe 'with a larger number' do
          let(:count) { 3 }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        wrap_context 'when the data has many items' do
          describe 'with zero' do
            let(:count) { 0 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be 0 }

            it { expect(subquery.to_a).to be == [] }
          end

          describe 'with one' do
            let(:count) { 1 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be count }

            it { expect(subquery.to_a).to be == raw_data[0...count] }
          end

          describe 'with three' do
            let(:count) { 3 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be count }

            it { expect(subquery.to_a).to be == raw_data[0...count] }
          end

          describe 'with the number of items' do
            let(:count) { raw_data.count }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be count }

            it { expect(subquery.to_a).to be == raw_data[0...count] }
          end

          describe 'with greater than the number of items' do
            let(:count) { raw_data.count + 3 }

            it { expect(query.count).to be raw_data.count }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be raw_data.count }

            it { expect(subquery.to_a).to be == raw_data }
          end
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          describe 'with zero' do
            let(:count) { 0 }

            it { expect(query.count).to be expected_data.count }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be 0 }

            it { expect(subquery.to_a).to be == [] }
          end

          describe 'with one' do
            let(:count) { 1 }

            it { expect(query.count).to be expected_data.count }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be count }

            it { expect(subquery.to_a).to be == expected_data[0...count] }
          end

          describe 'with the number of items' do
            let(:count) { expected_data.count }

            it { expect(query.count).to be expected_data.count }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be count }

            it { expect(subquery.to_a).to be == expected_data[0...count] }
          end

          describe 'with greater than the number of items' do
            let(:count) { expected_data.count + 3 }

            it { expect(query.count).to be expected_data.count }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.count }

            it { expect(subquery.to_a).to be == expected_data }
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
            'invalid selector - nil'
          end

          it 'should raise an error' do
            expect { query.matching(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:object) { Object.new }
          let(:error_message) do
            "invalid selector - #{object.inspect}"
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

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        describe 'with a value selector' do
          let(:selector) { { 'title' => 'Savage Pellucidar' } }

          it { expect(query.count).to be 0 }

          it { expect(query.to_a).to be == [] }

          it { expect(subquery.count).to be 0 }

          it { expect(subquery.to_a).to be == [] }
        end

        wrap_context 'when the data has many items' do
          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be raw_data.size }

            it { expect(subquery.to_a).to be == raw_data }
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be 0 }

            it { expect(subquery.to_a).to be == [] }
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'series' => 'Barsoom' } }
            let(:expected) do
              raw_data.select { |item| item['series'] == 'Barsoom' }
            end

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be expected.size }

            it { expect(subquery.to_a).to be == expected }
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be raw_data.size }

            it { expect(subquery.to_a).to be == raw_data }
          end

          describe 'with a value selector with symbol keys' do
            let(:selector) { { series: 'Barsoom' } }
            let(:expected) do
              raw_data.select { |item| item['series'] == 'Barsoom' }
            end

            it { expect(query.count).to be raw_data.size }

            it { expect(query.to_a).to be == raw_data }

            it { expect(subquery.count).to be expected.size }

            it { expect(subquery.to_a).to be == expected }
          end
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          describe 'with an empty selector' do
            let(:selector) { {} }

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected_data }
          end

          describe 'with a value selector that does not match any items' do
            let(:selector) { { 'author' => 'C. S. Lewis' } }

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be 0 }

            it { expect(subquery.to_a).to be == [] }
          end

          describe 'with a value selector that matches some items' do
            let(:selector) { { 'index' => 2 } }
            let(:expected) do
              expected_data.select { |item| item['index'] == 2 }
            end

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected.size }

            it { expect(subquery.to_a).to be == expected }
          end

          describe 'with a value selector that matches all items' do
            let(:selector) { { 'author' => 'Edgar Rice Burroughs' } }

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected_data }
          end
        end
      end

      describe '#order' do
        shared_examples 'should sort the data by one attribute' \
        do |reversed: false|
          context 'when no items have the attribute' do
            let(:attribute) { 'attributions' }

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected_data }
          end

          context 'when some items have the attribute' do
            let(:attribute) { 'series' }
            let(:items_without_attribute) do
              expected_data.select { |item| item['series'].nil? }
            end
            let(:sorted_ascending) do
              expected_data
                .reject { |item| item['series'].nil? }
                .sort_by { |item| item['series'] } +
                items_without_attribute
            end
            let(:sorted_descending) do
              items_without_attribute +
                expected_data
                .reject { |item| item['series'].nil? }
                .sort { |u, v| v['series'] <=> u['series'] }
            end
            let(:expected) { reversed ? sorted_descending : sorted_ascending }

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected }
          end

          context 'when all items have the attribute' do
            let(:attribute) { 'title' }
            let(:sorted)    { expected_data.sort_by { |item| item['title'] } }
            let(:expected)  { reversed ? sorted.reverse : sorted }

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected }
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
            let(:expected) do
              expected_data
                .each.with_index.sort do |(u, ui), (v, vi)|
                  compare_series(u, v) || compare_title(u, v) || (ui <=> vi)
                end
                .map(&:first)
            end

            def compare_series(first, second)
              first_series  = first['series']
              second_series = second['series']

              return if first_series.nil? && second_series.nil?

              return 1 if first_series.nil?

              return -1 if second_series.nil?

              cmp = first_series <=> second_series

              cmp.zero? ? nil : cmp
            end

            def compare_title(first, second)
              cmp = first['title'] <=> second['title']

              cmp.zero? ? nil : cmp
            end

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected }
          end

          describe 'with a Hash with multiple valid key-value pairs' do
            let(:subquery) { query.order(series: :asc, title: :desc) }
            let(:expected) do
              expected_data
                .each.with_index.sort do |(u, ui), (v, vi)|
                  compare_series(u, v) || compare_title(u, v) || (ui <=> vi)
                end
                .map(&:first)
            end

            def compare_series(first, second)
              first_series  = first['series']
              second_series = second['series']

              return if first_series.nil? && second_series.nil?

              return 1 if first_series.nil?

              return -1 if second_series.nil?

              cmp = first_series <=> second_series

              cmp.zero? ? nil : cmp
            end

            def compare_title(first, second)
              cmp = first['title'] <=> second['title']

              cmp.zero? ? nil : -cmp
            end

            it { expect(query.count).to be expected_data.size }

            it { expect(query.to_a).to be == expected_data }

            it { expect(subquery.count).to be expected_data.size }

            it { expect(subquery.to_a).to be == expected }
          end
        end

        let(:attributes)    { %w[title] }
        let(:subquery)      { query.order(*attributes) }
        let(:expected_data) { raw_data }

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
            "invalid selector - #{object.inspect}"
          end

          it 'should raise an error' do
            expect { query.matching(object) }
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
      end

      describe '#to_a' do
        it { expect(query.to_a).to be == [] }

        wrap_context 'when the data has many items' do
          it { expect(query.to_a).to be == raw_data }
        end

        wrap_context 'when the query has a matching filter' do
          include_context 'when the data has many items'

          it { expect(query.to_a).to be == expected_data }
        end
      end
    end
  end
end
