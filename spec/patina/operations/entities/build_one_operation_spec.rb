# spec/patina/operations/entities/build_one_operation_spec.rb

require 'patina/collections/simple'
require 'patina/operations/entities/build_one_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::BuildOneOperation do
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new resource_class }

  options = { :base_class => Spec::ExampleEntity }
  mock_class Spec, :ArchivedPeriodical, options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    shared_examples 'should build the resource and return true' do
      it { expect(instance.call attributes).to be true }

      it 'should set the resource' do
        instance.call attributes

        expect(instance.resource).to be_a resource_class

        received = instance.resource.attributes
        expect(received.delete :id).to be_a String
        expect(received).to be == expected
      end # it

      it 'should clear the failure message' do
        instance.call attributes

        expect(instance.failure_message).to be nil
      end # it

      it 'should clear the errors' do
        instance.call attributes

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    let(:expected) do
      attribute_values = attributes || {}

      resource_class.attributes.each.with_object({}) do |(key, metadata), hsh|
        next if key == :id

        hsh[key] = attribute_values.fetch(
          key,
          attribute_values.fetch(key.to_s, metadata.default)
        ) # end fetch
      end # each_key
    end # let

    describe 'with nil' do
      let(:attributes) { nil }

      include_examples 'should build the resource and return true'
    end # describe

    describe 'with an empty hash' do
      let(:attributes) { {} }

      include_examples 'should build the resource and return true'
    end # describe

    describe 'with a hash with string keys' do
      let(:attributes) do
        { 'title' => 'Journal of Phrenology', 'volume' => 13 }
      end # let

      include_examples 'should build the resource and return true'
    end # describe

    describe 'with a hash with symbol keys' do
      let(:attributes) do
        { :title => 'Journal of Phrenology', :volume => 13 }
      end # let

      include_examples 'should build the resource and return true'
    end # describe
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
