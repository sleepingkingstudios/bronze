# spec/bronze/operations/resources/many_resources_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/operations/resources/many_resources_operation'
require 'bronze/operations/resources/resource_operation_examples'

RSpec.describe Bronze::Operations::Resources::ManyResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::ManyResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = {
    :base_class => Bronze::Operations::Resources::ManyResourcesOperation
  } # end options
  mock_class Spec, :ManyResourcesOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ManyResourcesOperation methods'
end # describe
