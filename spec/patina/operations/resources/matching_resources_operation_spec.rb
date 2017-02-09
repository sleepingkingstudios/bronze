# spec/patina/operations/resources/matching_resources_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/matching_resources_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::MatchingResourcesOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::MatchingResourcesOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :MatchingResourcesOperation, options do |klass|
    klass.send :include,
      Patina::Operations::Resources::MatchingResourcesOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the MatchingResourcesOperation methods'
end # describe
