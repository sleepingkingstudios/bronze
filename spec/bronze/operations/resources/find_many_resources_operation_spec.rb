# spec/bronze/operations/resources/find_many_resources_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/entities/entity'
require 'bronze/operations/resources/find_many_resources_operation'
require 'bronze/operations/resources/resource_operation_examples'

RSpec.describe Bronze::Operations::Resources::FindManyResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  let(:resource_class)  { Spec::ArchivedPeriodical }
  let(:described_class) { Spec::FindManyResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  mock_class Spec, :ArchivedPeriodical, :base_class => Bronze::Entities::Entity

  options = {
    :base_class => Bronze::Operations::Resources::FindManyResourcesOperation
  } # end options
  mock_class Spec, :FindManyResourcesOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ManyResourcesOperation methods'

  describe '#call' do
    shared_examples 'should set the resources' do
      it { expect(instance.call(*arguments)).to be true }

      it 'should set the resources' do
        instance.call(*arguments)

        expect(instance.resources).to be == expected
      end # it

      it 'should clear the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call(*arguments)

        expect(instance.errors).to satisfy(&:empty?)
      end # it
    end # shared_examples

    let(:collection) { instance.resource_collection }
    let(:expected)   { Array.new(3) { double('entity') } }
    let(:query)      { double('query') }
    let(:arguments)  { [] }

    before(:example) do
      allow(collection).to receive(:query).and_return(query)

      allow(query).to receive(:to_a).and_return(expected)
    end # before example

    it { expect(instance).to respond_to(:call).with(0).arguments }

    include_examples 'should set the resources'

    describe 'with :matching => selector' do
      let(:selector)  { { :author => 'J.R.R. Tolkien' } }
      let(:arguments) { [{ :matching => selector }] }

      before(:example) do
        expect(query).to receive(:matching).with(selector).and_return(query)
      end # before example

      include_examples 'should set the resources'
    end # describe
  end # describe
end # describe
