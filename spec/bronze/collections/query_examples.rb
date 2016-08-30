# spec/bronze/collections/query_examples.rb

require 'bronze/collections/criteria/match_criterion'
require 'bronze/collections/null_query'
require 'bronze/transforms/attributes_transform'

module Spec::Collections
  module QueryExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the data contains many items' do
      let(:data) do
        [
          {
            :id     => '1',
            :title  => 'The Fellowship of the Ring',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '2',
            :title  => 'The Two Towers',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '3',
            :title  => 'The Return of the King',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '4',
            :title  => 'A Princess of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
          {
            :id     => '5',
            :title  => 'The Gods of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
          {
            :id     => '6',
            :title  => 'The Warlord of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
        ] # end array
      end # let
    end # shared_context

    shared_context 'when a transform is set' do
      let(:transform_class) do
        Class.new(Bronze::Transforms::AttributesTransform) do
          attributes :title
        end # class
      end # let
      let(:entity_class) do
        Struct.new(:id, :title)
      end # let
      let(:transform) do
        transform_class.new(entity_class)
      end # let
    end # shared_context

    shared_examples 'should implement the Query interface' do
      describe '#count' do
        it { expect(instance).to respond_to(:count).with(0).arguments }
      end # describe

      describe '#criteria' do
        it { expect(instance).to respond_to(:criteria, true).with(0).arguments }
      end # describe

      describe '#each' do
        it 'should define the method' do
          expect(instance).to respond_to(:each).with(0).arguments.and_a_block
        end # it
      end # describe

      describe '#exists?' do
        it { expect(instance).to respond_to(:exists?).with(0).arguments }
      end # describe

      describe '#limit' do
        it { expect(instance).to respond_to(:limit).with(1).argument }
      end # describe

      describe '#matching' do
        it { expect(instance).to respond_to(:matching).with(1).argument }
      end # describe

      describe '#one' do
        it { expect(instance).to respond_to(:one).with(0).arguments }
      end # describe

      describe '#none' do
        it { expect(instance).to respond_to(:none).with(0).arguments }
      end # describe

      describe '#to_a' do
        it { expect(instance).to respond_to(:to_a).with(0).arguments }
      end # describe

      describe '#transform' do
        include_examples 'should have reader', :transform
      end # describe
    end # shared_examples

    shared_examples 'should return a copy of the query' do
      it 'should return a copy of the query' do
        query = perform_action

        expect(query).to be_a described_class
        expect(query).not_to be instance
      end # it
    end # shared_examples

    shared_examples 'should run queries against the datastore' do
      describe '#count' do
        it { expect(instance.count).to be 0 }

        wrap_context 'when the data contains many items' do
          it { expect(instance.count).to be data.count }
        end # wrap_context
      end # describe

      describe '#each' do
        it 'should not yield any items' do
          yielded = []

          instance.each { |obj| yielded << obj }

          expect(yielded).to be == []
        end # it

        wrap_context 'when the data contains many items' do
          let(:expected) { data }

          it 'should yield the items' do
            yielded = []

            instance.each { |obj| yielded << obj }

            expect(yielded).to contain_exactly(*expected)
          end # it

          wrap_context 'when a transform is set' do
            let(:expected) do
              super().map { |hsh| instance.transform.denormalize hsh }
            end # let

            it 'should return the results as an array of entities' do
              yielded = []

              instance.each { |obj| yielded << obj }

              expect(yielded).to contain_exactly(*expected)
            end # it
          end # wrap_context
        end # wrap_context
      end # describe

      describe '#exists?' do
        it { expect(instance.exists?).to be false }

        wrap_context 'when the data contains many items' do
          it { expect(instance.exists?).to be true }
        end # wrap_context
      end # describe

      describe '#limit' do
        shared_examples 'should return the requested number of items' do
          it 'should return the requested number of items' do
            query = instance.limit(count)

            expect(query.count).to be [count, data.count].min
            expect(query.to_a).to be == expected
          end # it
        end # shared_examples

        let(:count) { 3 }
        let(:expected) do
          data[0...count]
        end # let

        include_examples 'should return the requested number of items'

        wrap_context 'when the data contains many items' do
          describe 'with a limit of 0' do
            let(:count) { 0 }

            include_examples 'should return the requested number of items'
          end # describe

          describe 'with a limit of 1' do
            let(:count) { 1 }

            include_examples 'should return the requested number of items'
          end # describe

          describe 'with a limit of 3' do
            let(:count) { 3 }

            include_examples 'should return the requested number of items'
          end # describe

          describe 'with a limit of 6' do
            let(:count) { 6 }

            include_examples 'should return the requested number of items'
          end # describe

          describe 'with a limit of 10' do
            let(:count) { 10 }

            include_examples 'should return the requested number of items'
          end # describe
        end # wrap_context
      end # describe

      describe '#matching' do
        shared_examples 'should return the items matching the selector' do
          it 'should return the items matching the selector' do
            query = instance.matching(selector)

            expect(query.count).to be expected.count
            expect(query.to_a).to be == expected
          end # it
        end # shared_examples

        let(:selector) { { :id => '0' } }
        let(:expected) do
          data.select { |hsh| hsh >= selector }
        end # let

        include_examples 'should return the items matching the selector'

        wrap_context 'when the data contains many items' do
          # rubocop:disable Metrics/LineLength
          shared_examples 'should filter the results using the given selector' do
            # rubocop:enable Metrics/LineLength
            describe 'with an id selector that does not match an item' do
              let(:selector) { { :id => '0' } }

              include_examples 'should return the items matching the selector'
            end # describe

            describe 'with an id selector that matches an item' do
              let(:selector) { { :id => '1' } }

              include_examples 'should return the items matching the selector'
            end # describe

            # rubocop:disable Metrics/LineLength
            describe 'with an attributes selector that does not match any items' do
              # rubocop:enable Metrics/LineLength
              let(:selector) { { :author => 'C.S. Lewis' } }

              include_examples 'should return the items matching the selector'
            end # describe

            describe 'with an attributes selector that matches one item' do
              let(:selector) { { :title => 'The Two Towers' } }

              include_examples 'should return the items matching the selector'
            end # describe

            describe 'with an attributes selector that matches many items' do
              let(:selector) { { :author => 'J.R.R. Tolkien' } }

              include_examples 'should return the items matching the selector'
            end # describe

            describe 'with a multi-attribute selector' do
              let(:selector) do
                {
                  :title  => 'A Princess of Mars',
                  :author => 'Edgar Rice Burroughs'
                } # end hash
              end # let

              include_examples 'should return the items matching the selector'
            end # describe
          end # shared_examples

          include_examples 'should filter the results using the given selector'

          describe 'with a chained selector' do
            let(:first_selector) do
              { :title  => 'The Warlord of Mars' }
            end # let
            let(:second_selector) do
              { :author => 'Edgar Rice Burroughs' }
            end # let
            let(:expected) do
              data.select { |hsh| hsh >= first_selector }.
                select { |hsh| hsh >= second_selector }
            end # let

            it 'should return the items matching the selector' do
              query = instance.matching(first_selector)
              query = query.matching(second_selector)

              expect(query.count).to be 1
              expect(query.to_a).to be == expected
            end # it
          end # describe

          wrap_context 'when a transform is set' do
            let(:expected) do
              super().map { |hsh| instance.transform.denormalize hsh }
            end # let

            # rubocop:disable Metrics/LineLength
            include_examples 'should filter the results using the given selector'
            # rubocop:enable Metrics/LineLength

            describe 'with a chained selector' do
              let(:first_selector) do
                { :title  => 'The Warlord of Mars' }
              end # let
              let(:second_selector) do
                { :author => 'Edgar Rice Burroughs' }
              end # let
              let(:expected) do
                data.select { |hsh| hsh >= first_selector }.
                  select { |hsh| hsh >= second_selector }.
                  map { |hsh| instance.transform.denormalize hsh }
              end # let

              it 'should filter the results array' do
                query = instance.matching(first_selector)
                query = query.matching(second_selector)

                expect(query.count).to be 1
                expect(query.to_a).to be == expected
              end # it
            end # describe
          end # wrap_context
        end # wrap_context
      end # describe

      describe '#one' do
        it { expect(instance.one).to be nil }

        wrap_context 'when the data contains many items' do
          it { expect(instance.one).to be nil }

          context 'when the results contain one item' do
            it 'should return the item' do
              expect(instance.limit(1).one).to be == data[0]
            end # it

            wrap_context 'when a transform is set' do
              let(:expected) { instance.transform.denormalize data[0] }

              it 'should return the item' do
                expect(instance.limit(1).one).to be == expected
              end # it
            end # wrap_context
          end # context
        end # wrap_context
      end # describe

      describe '#none' do
        it 'should return a null query' do
          query = instance.none

          expect(query).to be_a Bronze::Collections::NullQuery
        end # it
      end # describe

      describe '#to_a' do
        it 'should return an empty results array' do
          results = instance.to_a

          expect(results).to be == []
        end # it

        wrap_context 'when the data contains many items' do
          let(:expected) { data }

          it 'should return the results array' do
            results = instance.to_a

            expect(results).to contain_exactly(*expected)
          end # it

          wrap_context 'when a transform is set' do
            let(:expected) do
              super().map { |hsh| instance.transform.denormalize hsh }
            end # let

            it 'should return the results as an array of entities' do
              results = instance.to_a

              expect(results).to contain_exactly(*expected)
            end # it
          end # wrap_context
        end # wrap_context
      end # describe

      describe 'chaining criteria' do
        shared_examples 'should return the items matching the criteria' do
          it 'should return the items matching the criteria' do
            expect(query.count).to be expected.count
            expect(query.exists?).to be(expected.count > 0)
            expect(query.to_a).to be == expected
          end # it
        end # shared_examples

        describe 'with a :limit followed by a :matching' do
          let(:selector) { { :author => 'Edgar Rice Burroughs' } }
          let(:count)    { 2 }
          let(:query)    { instance.limit(count).matching(selector) }
          let(:expected) do
            data.select { |hsh| hsh >= selector }[0...count]
          end # let

          include_examples 'should return the items matching the criteria'

          wrap_context 'when the data contains many items' do
            include_examples 'should return the items matching the criteria'
          end # wrap_context
        end # describe

        describe 'with a :matching followed by a :limit' do
          let(:selector) { { :author => 'Edgar Rice Burroughs' } }
          let(:count)    { 2 }
          let(:query)    { instance.matching(selector).limit(count) }
          let(:expected) do
            data.select { |hsh| hsh >= selector }[0...count]
          end # let

          include_examples 'should return the items matching the criteria'

          wrap_context 'when the data contains many items' do
            include_examples 'should return the items matching the criteria'
          end # wrap_context
        end # describe
      end # describe
    end # shared_examples

    shared_examples 'should implement the Query methods' do
      include_examples 'should run queries against the datastore'

      describe '#limit' do
        let(:criterion_class) do
          Bronze::Collections::Criteria::LimitCriterion
        end # let
        let(:count) { 3 }

        def perform_action
          instance.limit count
        end # method perform_action

        include_examples 'should return a copy of the query'

        it 'should add a limit criterion to the copy' do
          query = instance.limit count

          criterion = query.send(:criteria).last
          expect(criterion).to be_a criterion_class
          expect(criterion.count).to be == count
        end # it

        it 'should not mutate the query' do
          expect { instance.limit count }.
            not_to change(instance.send(:criteria), :count)
        end # it
      end # describe

      describe '#matching' do
        let(:criterion_class) do
          Bronze::Collections::Criteria::MatchCriterion
        end # let
        let(:selector) { { :id => '0' } }

        def perform_action
          instance.matching selector
        end # method perform_action

        include_examples 'should return a copy of the query'

        it 'should add a match criterion to the copy' do
          query = instance.matching selector

          criterion = query.send(:criteria).last
          expect(criterion).to be_a criterion_class
          expect(criterion.selector).to be == selector
        end # it

        it 'should not mutate the query' do
          expect { instance.matching selector }.
            not_to change(instance.send(:criteria), :count)
        end # it
      end # describe
    end # shared_examples
  end # module
end # module
