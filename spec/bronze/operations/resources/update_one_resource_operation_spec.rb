# spec/bronze/operations/resources/update_one_resource_operation_spec.rb

require 'bronze/collections/reference/repository'
require 'bronze/operations/resources/resource_operation_examples'
require 'bronze/operations/resources/update_one_resource_operation'

RSpec.describe Bronze::Operations::Resources::UpdateOneResourceOperation do
  include Spec::Operations::ResourceOperationExamples

  include_context 'when a resource class is defined'

  let(:described_class) { Spec::UpdateOneResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  options = {
    :base_class => Bronze::Operations::Resources::UpdateOneResourceOperation
  } # end options
  mock_class Spec, :UpdateOneResourceOperation, options do |klass|
    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  include_examples 'should implement the OneResourceOperation methods'

  describe '#call' do
    let(:attributes)  { {} }
    let(:resource_id) { '0' }

    def call_operation
      instance.call resource_id, attributes
    end # method call_operation

    include_context 'should require a resource'

    wrap_context 'when the collection contains one resource' do
      include_context 'should require a resource'

      describe 'with a valid resource id' do
        let(:resource_id) { resource.id }
        let(:attributes)  { { :volume => 7 } }

        describe 'with a failing update' do
          let(:errors) do
            Bronze::Errors::Errors.new.tap do |errors|
              errors[:user].add :not_authorized
            end # tap
          end # let

          before(:example) do
            allow(instance.resource_collection).to receive(:update) do |*|
              [false, errors]
            end # allow
          end # before example

          it { expect(instance.call resource_id, attributes).to be false }

          it 'should set the resource' do
            instance.call resource_id, attributes

            resource = instance.resource

            expect(resource).to be_a resource_class
            expect(resource.title).to be == resource_attributes[:title]
            expect(resource.volume).to be == attributes[:volume]
          end # it

          it 'should not update the persisted resource' do
            collection = repository.collection(resource_class)

            expect { instance.call resource_id, attributes }.
              not_to change { collection.find resource_id }
          end # it

          it 'should set the errors' do
            previous_errors = Bronze::Errors::Errors.new
            previous_errors[:resources].add :require_more_minerals
            previous_errors[:resources].add :insufficient_vespene_gas

            instance.instance_variable_set :@errors, previous_errors

            instance.call resource_id, attributes

            expect(instance.errors).to be == errors
          end # it
        end # describe

        describe 'with a successful update' do
          it { expect(instance.call resource_id, attributes).to be true }

          it 'should set the resource' do
            instance.call resource_id, attributes

            resource = instance.resource

            expect(resource).to be_a resource_class
            expect(resource.title).to be == resource_attributes[:title]
            expect(resource.volume).to be == attributes[:volume]
          end # it

          it 'should update the persisted resource' do
            transform  =
              Bronze::Entities::Transforms::EntityTransform.new(resource_class)
            collection = repository.collection(resource_class, transform)

            expect { instance.call resource_id, attributes }.
              to change { collection.find resource_id }

            expect(collection.find resource_id).to be == instance.resource
          end # it

          it 'should clear the errors' do
            previous_errors = Bronze::Errors::Errors.new
            previous_errors[:resources].add :require_more_minerals
            previous_errors[:resources].add :insufficient_vespene_gas

            instance.instance_variable_set :@errors, previous_errors

            instance.call resource_id, attributes

            expect(instance.errors).to satisfy(&:empty?)
          end # it
        end # describe
      end # describe
    end # wrap_context
  end # describe
end # describe
