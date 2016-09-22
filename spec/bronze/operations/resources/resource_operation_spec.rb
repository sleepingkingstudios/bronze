# spec/bronze/operations/resources/resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/operations/resources/resource_operation'
require 'bronze/operations/resources/resource_operation_examples'

RSpec.describe Bronze::Operations::Resources::ResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  let(:resource_class) do
    Class.new do
      def self.name
        'Publications::ArchivedPeriodical'
      end # class method name
    end # class
  end # let
  let(:described_class) { Spec::ResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  mock_class Spec, :ResourceOperation do |klass|
    klass.send :include, Bronze::Operations::Resources::ResourceOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ResourceOperation methods'
end # describe
