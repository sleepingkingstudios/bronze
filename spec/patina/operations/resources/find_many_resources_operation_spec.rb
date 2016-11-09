# spec/patina/operations/resources/find_many_resources_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'patina/operations/resources/find_many_resources_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::FindManyResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::FindManyResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = {
    :base_class => Patina::Operations::Resources::FindManyResourcesOperation
  } # end options
  mock_class Spec::Operations, :FindManyResourcesOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ManyResourcesOperation methods'

  describe '#call' do
    shared_examples 'should find the resources' do
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

    let(:expected)  { [] }
    let(:arguments) { [] }

    it { expect(instance).to respond_to(:call).with(0).arguments }

    include_examples 'should find the resources'

    wrap_context 'when the collection contains many resources' do
      let(:expected) { resources }

      include_examples 'should find the resources'
    end # wrap_context

    describe 'with :matching => selector' do
      let(:selector)  { { :title => 'Journal of Applied Phrenology' } }
      let(:arguments) { super() << { :matching => selector } }

      include_examples 'should find the resources'

      wrap_context 'when the collection contains many resources' do
        let(:expected) do
          resources.select do |resource|
            resource.title == selector[:title]
          end # select
        end # let

        include_examples 'should find the resources'
      end # wrap_context
    end # describe
  end # describe
end # describe
