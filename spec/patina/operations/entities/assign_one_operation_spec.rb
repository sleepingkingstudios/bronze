# spec/patina/operations/entities/assign_one_operation_spec.rb

require 'patina/operations/entities/assign_one_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::AssignOneOperation do
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new }

  options = { :base_class => Spec::ExampleEntity }
  mock_class Spec, :ArchivedPeriodical, options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#call' do
    shared_examples 'should assign the attributes and return true' do
      it { expect(instance.call resource, attributes).to be true }

      it 'should set the resource' do
        instance.call resource, attributes

        expect(instance.resource).to be resource

        received = instance.resource.attributes
        expect(received.delete :id).to be_a String
        expect(received).to be == expected
      end # it

      it 'should clear the failure message' do
        instance.call resource, attributes

        expect(instance.failure_message).to be nil
      end # it

      it 'should clear the errors' do
        instance.call resource, attributes

        expect(instance.errors.empty?).to be true
      end # it
    end # shared_examples

    let(:resource_attributes) do
      {}
    end # let
    let(:resource)   { resource_class.new resource_attributes }
    let(:attributes) { {} }
    let(:expected) do
      hash_tools       = SleepingKingStudios::Tools::HashTools
      attribute_values = hash_tools.convert_keys_to_symbols(attributes)
      attribute_values = resource_attributes.merge(attribute_values)

      resource_class.attributes.each.with_object({}) do |(key, metadata), hsh|
        next if key == :id

        hsh[key] = attribute_values.fetch(
          key,
          attribute_values.fetch(key.to_s, metadata.default)
        ) # end fetch
      end # each_key
    end # let

    describe 'with nil' do
      it 'should raise an error' do
        expect { instance.call nil, {} }.
          to raise_error ArgumentError, "resource can't be nil"
      end # it
    end # describe

    describe 'with a resource and an empty hash' do
      include_examples 'should assign the attributes and return true'
    end # describe

    describe 'with a resource and a hash with string keys' do
      let(:attributes) do
        { 'title' => 'Journal of Phrenology', 'volume' => 13 }
      end # let

      include_examples 'should assign the attributes and return true'
    end # describe

    describe 'with a resource and a hash with symbol keys' do
      let(:attributes) do
        { :title => 'Journal of Phrenology', :volume => 13 }
      end # let

      include_examples 'should assign the attributes and return true'
    end # describe

    context 'when the resource has existing attributes' do
      let(:resource_attributes) do
        { :title => 'Your Daily Horoscope', :volume => 4 }
      end # let

      describe 'with a resource and an empty hash' do
        include_examples 'should assign the attributes and return true'
      end # describe

      describe 'with a resource and a hash with string keys' do
        let(:attributes) { { 'volume' => 13 } }

        include_examples 'should assign the attributes and return true'
      end # describe

      describe 'with a resource and a hash with symbol keys' do
        let(:attributes) { { :volume => 13 } }

        include_examples 'should assign the attributes and return true'
      end # describe
    end # context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
