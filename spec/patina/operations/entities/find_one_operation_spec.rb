# spec/patina/operations/entities/find_one_operation_spec.rb

require 'patina/collections/simple'
require 'patina/operations/entities/find_one_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::FindOneOperation do
  shared_context 'when the collection contains many resources' do
    let(:resources_attributes) do
      ary = []

      title = 'Astrology Today'
      1.upto(3) { |i| ary << { :title => title, :volume => i } }

      title = 'Journal of Applied Phrenology'
      4.upto(6) { |i| ary << { :title => title, :volume => i } }

      ary
    end # let
    let(:resources) do
      resources_attributes.map { |hsh| resource_class.new hsh }
    end # let

    before(:example) do
      resources.each do |resource|
        instance.send(:collection).insert resource
      end # each
    end # before
  end # shared_context

  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }

  options = { :base_class => Spec::ExampleEntity }
  mock_class Spec, :ArchivedPeriodical, options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  describe '::RECORD_NOT_FOUND' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_NOT_FOUND).
        with_value('operations.entities.record_not_found')
    end # it
  end # describe

  describe '#call' do
    describe 'with nil' do
      it 'should raise an error' do
        expect { instance.call nil }.
          to raise_error ArgumentError, "can't be nil"
      end # it
    end # describe

    describe 'with a primary key that does not match a record' do
      let(:expected_error) do
        error_definitions = Bronze::Collections::Collection::Errors

        Bronze::Errors::Error.new [:archived_periodicals, primary_key.intern],
          error_definitions::RECORD_NOT_FOUND,
          :id => primary_key
      end # let
      let(:primary_key) { Bronze::Entities::Ulid.generate }

      it { expect(instance.call primary_key).to be false }

      it 'should not set the resource' do
        instance.call primary_key

        expect(instance.resource).to be nil
      end # it

      it 'should set the failure message' do
        instance.call primary_key

        expect(instance.failure_message).
          to be == described_class::RECORD_NOT_FOUND
      end # it

      it 'should append the error' do
        instance.call primary_key

        expect(instance.errors).to include expected_error
      end # it
    end # describe

    wrap_context 'when the collection contains many resources' do
      describe 'with nil' do
        it 'should raise an error' do
          expect { instance.call nil }.
            to raise_error ArgumentError, "can't be nil"
        end # it
      end # describe

      describe 'with a primary key that does not match a record' do
        let(:expected_error) do
          error_definitions = Bronze::Collections::Collection::Errors

          Bronze::Errors::Error.new [:archived_periodicals, primary_key.intern],
            error_definitions::RECORD_NOT_FOUND,
            :id => primary_key
        end # let
        let(:primary_key) { Bronze::Entities::Ulid.generate }

        it { expect(instance.call primary_key).to be false }

        it 'should not set the resource' do
          instance.call primary_key

          expect(instance.resource).to be nil
        end # it

        it 'should set the failure message' do
          instance.call primary_key

          expect(instance.failure_message).
            to be == described_class::RECORD_NOT_FOUND
        end # it

        it 'should append the error' do
          instance.call primary_key

          expect(instance.errors).to include expected_error
        end # it
      end # describe

      describe 'with a primary key that matches a record' do
        let(:resource)    { resources.first }
        let(:primary_key) { resource.id }

        it { expect(instance.call primary_key).to be true }

        it 'should set the resource' do
          instance.call primary_key

          expect(instance.resource).to be == resource
          expect(instance.resource.attributes_changed?).to be false
          expect(instance.resource.persisted?).to be true
        end # it

        it 'should clear the failure message' do
          instance.call primary_key

          expect(instance.failure_message).to be nil
        end # it

        it 'should append the error' do
          instance.call primary_key

          expect(instance.errors.empty?).to be true
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#repository' do
    include_examples 'should have reader', :repository, ->() { repository }
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe

  describe '#resource_class' do
    include_examples 'should have reader',
      :resource_class,
      ->() { resource_class }
  end # describe
end # describe
