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

      describe '#matching' do
        it { expect(query).to respond_to(:matching).with(1).argument }

        it { expect(query).to alias_method(:matching).as(:where) }
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

      describe '#matching' do
        let(:selector) { {} }
        let(:subquery) { query.matching(selector) }

        it { expect(query.matching(selector)).not_to be query }

        it { expect(query.matching(selector)).to be_a described_class }

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
