# spec/patina/operations/resources/many_resources_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/many_resources_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::ManyResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::ManyResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :ManyResourcesOperation, options do |klass|
    klass.send :include,
      Patina::Operations::Resources::ManyResourcesOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::RESOURCES_NOT_FOUND' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RESOURCES_NOT_FOUND).
        with_value('operations.resources.resources_not_found')
    end # it
  end # describe

  include_examples 'should implement the ManyResourcesOperation methods'
end # describe
