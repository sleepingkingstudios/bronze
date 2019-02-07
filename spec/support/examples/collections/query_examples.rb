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
            'series' => {
              'index' => 1,
              'title' => 'Barsoom'
            }
          },
          {
            'title'  => 'The Gods of Mars',
            'author' => 'Edgar Rice Burroughs',
            'series' => {
              'index' => 2,
              'title' => 'Barsoom'
            }
          },
          {
            'title'  => 'The Warlord of Mars',
            'author' => 'Edgar Rice Burroughs',
            'series' => {
              'index' => 3,
              'title' => 'Barsoom'
            }
          },
          {
            'title'  => 'Beyond The Farthest Star',
            'author' => 'Edgar Rice Burroughs'
          },
          {
            'title'  => 'The Lion, The Witch, and the Wardrobe',
            'author' => 'C. S. Lewis',
            'series' => {
              'index' => 1,
              'title' => 'The Chronicles of Narnia'
            }
          },
          {
            'title'  => 'Prince Caspian',
            'author' => 'C. S. Lewis',
            'series' => {
              'index' => 2,
              'title' => 'The Chronicles of Narnia'
            }
          }
        ]
      end
    end

    shared_examples 'should implement the Query interface' do
      describe '#count' do
        it { expect(query).to respond_to(:count).with(0).arguments }
      end

      describe '#each' do
        it { expect(query).to respond_to(:each).with(0).arguments }
      end

      describe '#to_a' do
        it { expect(query).to respond_to(:to_a).with(0).arguments }
      end
    end

    shared_examples 'should implement the Query methods' do
      describe '#count' do
        it { expect(query.count).to be 0 }

        wrap_context 'when the data has many items' do
          it { expect(query.count).to be == raw_data.size }
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
      end

      describe '#to_a' do
        it { expect(query.to_a).to be == [] }

        wrap_context 'when the data has many items' do
          it { expect(query.to_a).to be == raw_data }
        end
      end
    end
  end
end
