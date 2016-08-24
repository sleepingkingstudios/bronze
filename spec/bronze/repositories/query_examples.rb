# spec/bronze/repositories/query_examples.rb

module Spec::Repositories
  module QueryExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when many items are defined for the data' do
      let(:data) do
        [
          { :id => '1', :title => 'The Fellowship of the Ring' },
          { :id => '2', :title => 'The Two Towers' },
          { :id => '3', :title => 'The Return of the King' }
        ] # end array
      end # let
    end # shared_context

    shared_context 'when the data contains many items' do
      include_context 'when many items are defined for the data'
    end # shared_context

    shared_context 'when a transform is set' do
      let(:transform_class) do
        Class.new(Bronze::Entities::Transforms::AttributesTransform) do
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

      describe '#to_a' do
        it { expect(instance).to respond_to(:to_a).with(0).arguments }
      end # describe

      describe '#transform' do
        include_examples 'should have reader', :transform
      end # describe
    end # shared_examples

    shared_examples 'should implement the Query methods' do
      describe '#count' do
        it { expect(instance.count).to be 0 }

        wrap_context 'when the data contains many items' do
          it { expect(instance.count).to be data.count }
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
    end # shared_examples
  end # module
end # module
