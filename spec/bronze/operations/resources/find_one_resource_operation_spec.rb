# spec/bronze/operations/resources/find_one_resource_operation_spec.rb

require 'bronze/collections/collection'
require 'bronze/collections/reference/repository'
require 'bronze/entities/entity'
require 'bronze/operations/resources/find_one_resource_operation'
require 'bronze/operations/resources/resource_operation_examples'

RSpec.describe Bronze::Operations::Resources::FindOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  let(:resource_class)  { Spec::ArchivedPeriodical }
  let(:described_class) { Spec::FindOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  mock_class Spec, :ArchivedPeriodical, :base_class => Bronze::Entities::Entity

  options = {
    :base_class => Bronze::Operations::Resources::FindOneResourceOperation
  } # end options
  mock_class Spec, :FindOneResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'

  describe '#call' do
    let(:collection)  { instance.resource_collection }
    let(:expected)    { double('entity') }
    let(:query)       { double('query') }
    let(:resource_id) { '0' }

    before(:example) do
      allow(collection).to receive(:base_query).and_return(query)

      allow(query).to receive(:matching).and_return(query)
      allow(query).to receive(:limit).and_return(query)
    end # before example

    describe 'with an invalid resource id' do
      let(:errors) do
        error_definitions = Bronze::Collections::Collection::Errors

        Bronze::Errors::Errors.new.tap do |errors|
          errors[:resource].add(
            error_definitions::RECORD_NOT_FOUND,
            :id,
            resource_id
          ) # end add error
        end # tap
      end # let

      before(:example) { allow(query).to receive(:one).and_return(nil) }

      it { expect(instance.call resource_id).to be false }

      it 'should set the resource' do
        instance.call resource_id

        expect(instance.resource).to be nil
      end # it

      it 'should set the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call resource_id

        expect(instance.errors).to be == errors
      end # it
    end # describe

    describe 'with a valid resource id' do
      before(:example) { allow(query).to receive(:one).and_return(expected) }

      it { expect(instance.call resource_id).to be true }

      it 'should set the resource' do
        instance.call resource_id

        expect(instance.resource).to be == expected
      end # it

      it 'should clear the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call resource_id

        expect(instance.errors).to satisfy(&:empty?)
      end # it
    end # describe
  end # describe
end # describe
