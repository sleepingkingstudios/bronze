# spec/patina/operations/resources/one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'

require 'patina/operations/resources/one_resource_operation'
require 'patina/operations/resources/resource_operation_examples'

RSpec.describe Patina::Operations::Resources::OneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::Operations::OneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Operations::Operation }
  mock_class Spec::Operations, :OneResourceOperation, options do |klass|
    klass.send :include, Patina::Operations::Resources::OneResourceOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::INVALID_RESOURCE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:INVALID_RESOURCE).
        with_value('operations.resources.invalid_resource')
    end # it
  end # describe

  describe '::RESOURCE_NOT_FOUND' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RESOURCE_NOT_FOUND).
        with_value('operations.resources.resource_not_found')
    end # it
  end # describe

  include_examples 'should implement the OneResourceOperation methods'
end # describe
