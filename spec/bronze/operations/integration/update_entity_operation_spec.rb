require 'bronze/operations/assign_one_operation'
require 'bronze/operations/contract_operation'
require 'bronze/operations/persistence_operation'
require 'bronze/operations/update_one_operation'
require 'bronze/operations/validate_one_operation'

require 'support/examples/entity_operation_examples'

module Spec::Operations
  class UpdateEntityOperation < Bronze::Operations::AssignOneOperation
    include Bronze::Operations::ContractOperation
    include Bronze::Operations::PersistenceOperation

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param contract [Bronze::Constraints::Constraint] The contract to validate
    #   entities against. Defaults to no contract, in which case the entity will
    #   be validated using the contract defined for the entity class, if any.
    # @param repository [Bronze::Collections::Repository] The data repository to
    #   access or reference.
    # @param transform [Bronze::Transform] The transform used to serialize and
    #   deserialize entities to and from the repository.
    def initialize(*args, **kwargs)
      # RUBY_VERSION: Required below 2.5
      args << kwargs unless kwargs.empty?

      super(*args)

      chain!(validate_operation, on: :success)
      chain!(update_operation,   on: :success)
    end

    private

    def update_operation
      Bronze::Operations::UpdateOneOperation
        .new(
          entity_class: entity_class,
          repository:   repository,
          transform:    transform
        )
    end

    def validate_operation
      Bronze::Operations::ValidateOneOperation
        .new(
          entity_class: entity_class,
          contract:     contract
        )
    end
  end
end

RSpec.describe Spec::Operations::UpdateEntityOperation do
  include Spec::Support::Examples::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  subject(:instance) { described_class.new(**keywords) }

  let(:contract) { nil }
  let(:transform) { nil }
  let(:keywords) do
    {
      entity_class: entity_class,
      contract:     contract,
      repository:   repository,
      transform:    transform
    }
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :contract, :repository, :transform)
    end
  end

  include_examples 'should implement the ContractOperation methods'

  include_examples 'should implement the EntityOperation methods'

  describe '#call' do
    include_context 'when the repository has many entities'

    shared_examples 'should update the entity' do
      shared_examples 'should assign and update the entity' do
        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
          # expect(instance.result.value.persisted?).to be true
        end

        it 'should update the attributes', :aggregate_failures do
          call_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end

        it 'should update the persisted entity' do
          call_operation

          persisted = collection.find(entity.id)

          expected_attributes.each do |key, value|
            expect(persisted.send key).to be == value
          end
        end
      end

      describe 'with an entity that is not in the collection' do
        let(:entity) { entity_class.new }
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   => Bronze::Collections::Collection::Errors.record_not_found,
            :params => { :id => entity.id }
          }
        end

        def call_operation
          instance.call(entity, expected_attributes)
        end

        include_examples 'should fail and set the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
          expect(instance.result.value.persisted?).to be false
        end

        it 'should update the attributes', :aggregate_failures do
          call_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end

      describe 'with a valid attributes hash with string keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(valid_attributes)

          instance.call(entity, attributes)
        end

        include_examples 'should assign and update the entity'
      end

      describe 'with a valid attributes hash with symbol keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(valid_attributes)

          instance.call(entity, attributes)
        end

        include_examples 'should assign and update the entity'
      end

      wrap_context 'when the operation is defined with a contract' do
        let(:contract) { entity_contract }

        describe 'with an entity that is not in the collection' do
          let(:entity) { entity_class.new }
          let(:expected_error) do
            {
              :path   => [entity_name.intern],
              :type   =>
                Bronze::Collections::Collection::Errors.record_not_found,
              :params => { :id => entity.id }
            }
          end

          def call_operation
            instance.call(entity, expected_attributes)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be_a entity_class
            expect(instance.result.value.persisted?).to be false
          end

          it 'should update the attributes', :aggregate_failures do
            call_operation

            expected_attributes.each do |key, value|
              expect(entity.send key).to be == value
            end
          end
        end

        describe 'with an invalid attributes hash with string keys' do
          let(:expected_attributes) do
            entity.attributes.tap do |hsh|
              invalid_attributes.each do |key, value|
                hsh[key] = value
              end
            end
          end
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_strings(expected_attributes)

            instance.call(entity, attributes)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be_a entity_class
            expect(instance.result.value.persisted?).to be false
          end

          it 'should update the attributes', :aggregate_failures do
            call_operation

            expected_attributes.each do |key, value|
              expect(entity.send key).to be == value
            end
          end

          it 'should not update the persisted entity' do
            expect { call_operation }.
              not_to change { collection.find(entity.id).attributes }
          end
        end

        describe 'with an invalid attributes hash with symbol keys' do
          let(:expected_attributes) do
            entity.attributes.tap do |hsh|
              invalid_attributes.each do |key, value|
                hsh[key] = value
              end
            end
          end
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_symbols(expected_attributes)

            instance.call(entity, attributes)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be_a entity_class
            expect(instance.result.value.persisted?).to be false
          end

          it 'should update the attributes', :aggregate_failures do
            call_operation

            expected_attributes.each do |key, value|
              expect(entity.send key).to be == value
            end
          end

          it 'should not update the persisted entity' do
            expect { call_operation }.
              not_to change { collection.find(entity.id).attributes }
          end
        end

        describe 'with a valid attributes hash with string keys' do
          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_strings(valid_attributes)

            instance.call(entity, attributes)
          end

          include_examples 'should assign and update the entity'
        end

        describe 'with a valid attributes hash with symbol keys' do
          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_symbols(valid_attributes)

            instance.call(entity, attributes)
          end

          include_examples 'should assign and update the entity'
        end
      end
    end

    let(:entity) { collection.limit(1).one }
    let(:expected_attributes) do
      entity.attributes.tap do |hsh|
        valid_attributes.each do |key, value|
          hsh[key] = value
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(2).arguments }

    include_examples 'should update the entity'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should update the entity'
    end
  end
end
