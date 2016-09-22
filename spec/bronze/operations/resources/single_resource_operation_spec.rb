# spec/bronze/operations/resources/single_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/entities/entity'
require 'bronze/operations/resources/resource_operation_examples'
require 'bronze/operations/resources/single_resource_operation'
require 'bronze/entities/collections/entity_repository'

RSpec.describe Bronze::Operations::Resources::SingleResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  let(:resource_class) do
    Class.new(Bronze::Entities::Entity) do
      def self.name
        'Publications::ArchivedPeriodical'
      end # class method name
    end # class
  end # let
  let(:described_class) { Spec::SingleResourceOperation }
  let(:repository) do
    repo = Bronze::Collections::Reference::Repository.new
    repo.extend Bronze::Entities::Collections::EntityRepository
    repo
  end # let
  let(:instance) { described_class.new repository }

  options = {
    :base_class => Bronze::Operations::Resources::SingleResourceOperation
  } # end options
  mock_class Spec, :SingleResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the ResourceOperation methods'

  describe '#build_resource' do
    let(:attributes) { {} }

    it { expect(instance).to respond_to(:build_resource).with(1).argument }

    it 'should build an instance of the resource class' do
      resource = instance.build_resource attributes
      expected = attributes.merge(:id => resource.id)

      expect(resource).to be_a resource_class
      expect(resource.attributes).to be == expected
    end # it

    it 'should set the resource' do
      resource = nil

      expect { resource = instance.build_resource attributes }.
        to change(instance, :resource)

      expect(instance.resource).to be == resource
    end # it
  end # describe

  describe '#find_resource' do
    let(:id)         { '0' }
    let(:attributes) { { :id => id } }
    let(:resource)   { resource_class.new(attributes) }

    it { expect(instance).to respond_to(:find_resource).with(1).argument }

    context 'when the repository does not have the requested resource' do
      it 'should return nil' do
        expect(instance.find_resource id).to be nil
      end # it
    end # context

    context 'when the repository has the requested resource' do
      before(:example) { instance.collection.insert(resource) }

      it 'should return the resource' do
        expect(instance.find_resource id).to be == resource
      end # it
    end # context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, nil
  end # describe
end # describe
