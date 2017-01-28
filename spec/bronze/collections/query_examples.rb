# spec/bronze/collections/query_examples.rb

require 'bronze/collections/criteria/match_criterion'
require 'bronze/collections/null_query'
require 'bronze/collections/querying_examples'
require 'bronze/transforms/attributes_transform'

module Spec::Collections
  module QueryExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Collections::QueryingExamples

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

      describe '#none' do
        it { expect(instance).to respond_to(:none).with(0).arguments }
      end # describe

      describe '#one' do
        it { expect(instance).to respond_to(:one).with(0).arguments }
      end # describe

      describe '#pluck' do
        it { expect(instance).to respond_to(:pluck).with(1).argument }
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
        let(:expected_selector) do
          defined?(super()) ? super() : selector
        end # let

        def perform_action
          instance.matching selector
        end # method perform_action

        include_examples 'should return a copy of the query'

        it 'should add a match criterion to the copy' do
          query = instance.matching selector

          criterion = query.send(:criteria).last
          expect(criterion).to be_a criterion_class
          expect(criterion.selector).to be == expected_selector
        end # it

        it 'should not mutate the query' do
          expect { instance.matching selector }.
            not_to change(instance.send(:criteria), :count)
        end # it
      end # describe
    end # shared_examples
  end # module
end # module
