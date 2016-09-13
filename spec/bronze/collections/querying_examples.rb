# spec/bronze/collections/querying_examples.rb

module Spec::Collections
  module QueryingExamples
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

    shared_examples 'should return a query' do
      let(:query_class) { defined?(super()) ? super() : described_class }

      it 'should return a query' do
        expect(query).to be_a query_class
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

        include_examples 'should return a query' do
          let(:query) { instance.limit(count) }
        end # include_examples

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

        include_examples 'should return a query' do
          let(:query) { instance.matching(selector) }
        end # include_examples

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

      describe '#pluck' do
        it { expect(instance.pluck :id).to be == [] }

        wrap_context 'when the data contains many items' do
          describe 'with the name of a missing attribute' do
            let(:expected) { Array.new(data.count, nil) }

            it 'should return the values of the attributes' do
              proofreaders = instance.pluck :proofreader

              expect(proofreaders).to be_a Array
              expect(proofreaders.count).to be data.count
              expect(proofreaders).to contain_exactly(*expected)
            end # it
          end # describe

          describe 'with the name of an existing attribute' do
            it 'should return the values of the attributes' do
              ids = instance.pluck :id

              expect(ids).to be_a Array
              expect(ids.count).to be data.count
              expect(ids).to contain_exactly(*data.map { |hsh| hsh[:id] })
            end # it
          end # describe

          wrap_context 'when a transform is set' do
            describe 'with the name of a missing attribute' do
              let(:expected) { Array.new(data.count, nil) }

              it 'should return the values of the attributes' do
                proofreaders = instance.pluck :proofreader

                expect(proofreaders).to be_a Array
                expect(proofreaders.count).to be data.count
                expect(proofreaders).to contain_exactly(*expected)
              end # it
            end # describe

            describe 'with the name of an existing attribute' do
              it 'should return the values of the attributes' do
                ids = instance.pluck :id

                expect(ids).to be_a Array
                expect(ids.count).to be data.count
                expect(ids).to contain_exactly(*data.map { |hsh| hsh[:id] })
              end # it
            end # describe
          end # wrap_context
        end # wrap_context
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
  end # module
end # module
