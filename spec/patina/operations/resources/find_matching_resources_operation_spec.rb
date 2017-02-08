# spec/patina/operations/resources/find_matching_resources_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/find_matching_resources_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::FindMatchingResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::FindMatchingResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :FindMatchingResourcesOperation, options \
  do |klass|
    klass.send :include,
      Patina::Operations::Resources::FindMatchingResourcesOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the MatchingResourcesOperation methods'

  describe '#call' do
    shared_examples 'should find the resources' do
      it { expect(instance.call(*arguments)).to be true }

      it 'should set the resources' do
        instance.call(*arguments)

        expect(instance.resources).to be == expected

        instance.resources.each do |resource|
          expect(resource.attributes_changed?).to be false
          expect(resource.persisted?).to be true
        end # each
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