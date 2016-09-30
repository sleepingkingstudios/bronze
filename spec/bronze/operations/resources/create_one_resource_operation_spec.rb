# spec/bronze/operations/resources/create_one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/entities/entity'
require 'bronze/errors/errors'
require 'bronze/operations/resources/create_one_resource_operation'
require 'bronze/operations/resources/resource_operation_examples'

RSpec.describe Bronze::Operations::Resources::CreateOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  let(:resource_class)  { Spec::ArchivedPeriodical }
  let(:described_class) { Spec::CreateOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = { :base_class => Bronze::Entities::Entity }
  mock_class Spec, :ArchivedPeriodical, options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # mock_class

  options = {
    :base_class => Bronze::Operations::Resources::CreateOneResourceOperation
  } # end options
  mock_class Spec, :CreateOneResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'

  describe '#call' do
    let(:attributes) { { :title => 'Journal of Phrenology', :volume => 13 } }

    it { expect(instance).to respond_to(:call).with(1).argument }

    describe 'with a failing insert' do
      let(:errors) do
        Bronze::Errors::Errors.new.tap do |errors|
          errors[:user].add :not_authorized
        end # tap
      end # let

      before(:example) do
        allow(instance.resource_collection).to receive(:insert) do |_|
          [false, errors]
        end # allow
      end # before example

      it { expect(instance.call attributes).to be false }

      it 'should set the resource' do
        instance.call attributes

        resource = instance.resource

        expect(resource).to be_a resource_class
        expect(resource.title).to be == attributes[:title]
        expect(resource.volume).to be == attributes[:volume]
      end # it

      it 'should not persist the resource' do
        collection = repository.collection(resource_class)

        expect { instance.call attributes }.not_to change(collection, :count)
      end # it

      it 'should set the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call attributes

        expect(instance.errors).to be == errors
      end # it
    end # describe

    describe 'with a successful insert' do
      it { expect(instance.call attributes).to be true }

      it 'should set the resource' do
        instance.call attributes

        resource = instance.resource

        expect(resource).to be_a resource_class
        expect(resource.title).to be == attributes[:title]
        expect(resource.volume).to be == attributes[:volume]
      end # it

      it 'should persist the resource' do
        collection = repository.collection(resource_class)

        expect { instance.call attributes }.to change(collection, :count).by(1)
      end # it

      it 'should clear the errors' do
        previous_errors = Bronze::Errors::Errors.new
        previous_errors[:resources].add :require_more_minerals
        previous_errors[:resources].add :insufficient_vespene_gas

        instance.instance_variable_set :@errors, previous_errors

        instance.call attributes

        expect(instance.errors).to satisfy(&:empty?)
      end # it
    end # describe
  end # describe
end # describe
