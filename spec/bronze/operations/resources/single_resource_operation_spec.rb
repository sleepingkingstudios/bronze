# spec/bronze/operations/resources/single_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/entities/entity'
require 'bronze/operations/resources/resource_operation_examples'
require 'bronze/operations/resources/single_resource_operation'
require 'bronze/entities/collections/entity_repository'

RSpec.describe Bronze::Operations::Resources::SingleResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  let(:resource_class)  { Spec::ArchivedPeriodical }
  let(:described_class) { Spec::SingleResourceOperation }
  let(:repository) do
    repo = Bronze::Collections::Reference::Repository.new
    repo.extend Bronze::Entities::Collections::EntityRepository
    repo
  end # let
  let(:instance) { described_class.new repository }

  mock_class Spec, :ArchivedPeriodical, :base_class => Bronze::Entities::Entity

  options = {
    :base_class => Bronze::Operations::Resources::SingleResourceOperation
  } # end options
  mock_class Spec, :SingleResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the SingleResourceOperation methods'
end # describe
