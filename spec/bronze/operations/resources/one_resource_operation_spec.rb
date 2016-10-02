# spec/bronze/operations/resources/one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/operations/resources/one_resource_operation'
require 'bronze/operations/resources/resource_operation_examples'

RSpec.describe Bronze::Operations::Resources::OneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::OneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = {
    :base_class => Bronze::Operations::Resources::OneResourceOperation
  } # end options
  mock_class Spec, :OneResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'
end # describe
