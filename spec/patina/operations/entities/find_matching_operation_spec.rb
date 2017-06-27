# spec/patina/operations/entities/find_matching_operation_spec.rb

require 'patina/collections/simple'
require 'patina/operations/entities/entity_operation_examples'
require 'patina/operations/entities/find_matching_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::FindMatchingOperation do
  include Spec::Operations::EntityOperationExamples

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }

  options = { :base_class => Spec::ExampleEntity }
  example_class 'Spec::ArchivedPeriodical', options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # example_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '#call' do
    shared_examples 'should query for matching records' do
      it { expect(instance.call params).to be true }

      it 'should set the resources' do
        instance.call params

        expect(instance.resources).to be == expected

        instance.resources.each do |resource|
          expect(resource.attributes_changed?).to be false
          expect(resource.persisted?).to be true
        end # each
      end # it

      it 'should append the error' do
        instance.call params

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    let(:params)   { {} }
    let(:expected) { [] }

    describe 'with no options' do
      include_examples 'should query for matching records'
    end # describe

    describe 'with string params that do not match any records' do
      let(:params) { { 'matching' => { 'title' => 'Your Daily Horoscope' } } }

      include_examples 'should query for matching records'
    end # describe

    describe 'with symbol params that do not match any records' do
      let(:params) { { :matching => { :title => 'Your Daily Horoscope' } } }

      include_examples 'should query for matching records'
    end # describe

    wrap_context 'when the collection contains many resources' do
      describe 'with no options' do
        let(:expected) { resources }

        include_examples 'should query for matching records'
      end # describe

      describe 'with string params that do not match any records' do
        let(:params) { { 'matching' => { 'title' => 'Your Daily Horoscope' } } }

        include_examples 'should query for matching records'
      end # describe

      describe 'with symbol params that do not match any records' do
        let(:params) { { :matching => { :title => 'Your Daily Horoscope' } } }

        include_examples 'should query for matching records'
      end # describe

      describe 'with string params that match some records' do
        let(:params) { { 'matching' => { 'title' => 'Astrology Today' } } }
        let(:expected) do
          resources.select { |resource| resource.title == 'Astrology Today' }
        end # let

        include_examples 'should query for matching records'
      end # describe

      describe 'with symbol params that match some records' do
        let(:params) { { :matching => { :title => 'Astrology Today' } } }
        let(:expected) do
          resources.select { |resource| resource.title == 'Astrology Today' }
        end # let

        include_examples 'should query for matching records'
      end # describe
    end # wrap_context
  end # describe

  describe '#resources' do
    include_examples 'should have reader', :resources, nil
  end # describe
end # describe
