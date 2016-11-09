# spec/patina/operations/resources/resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'patina/operations/resources/resource_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::ResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::ResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  mock_class Spec::Operations, :ResourceOperation do |klass|
    klass.send :include, Patina::Operations::Resources::ResourceOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ResourceOperation methods'
end # describe
