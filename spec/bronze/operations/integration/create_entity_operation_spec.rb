require 'bronze/operations/build_one_operation'
require 'bronze/operations/contract_operation'
require 'bronze/operations/insert_one_operation'
require 'bronze/operations/persistence_operation'
require 'bronze/operations/validate_one_operation'

require 'support/examples/entity_operation_examples'

module Spec::Operations
  class CreateEntityOperation < Bronze::Operations::BuildOneOperation
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
      chain!(insert_operation,   on: :success)
    end

    private

    def insert_operation
      Bronze::Operations::InsertOneOperation
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

RSpec.describe Spec::Operations::CreateEntityOperation do
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

  include_examples 'should implement the PersistenceOperation methods'

  describe '#call' do
    shared_examples 'should create the entity' do
      shared_examples 'should build and insert the entity' do
        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
          expect(instance.result.value.persisted?).to be true
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be == expected_attributes[key]
          end
        end

        it { expect { call_operation }.to change(collection, :count).by(1) }
      end

      describe 'with no arguments' do
        let(:expected_attributes) { {} }

        def call_operation
          instance.call
        end

        include_examples 'should build and insert the entity'
      end

      describe 'with nil' do
        let(:expected_attributes) { {} }

        def call_operation
          instance.call(nil)
        end

        include_examples 'should build and insert the entity'
      end

      describe 'with an empty attributes hash' do
        let(:expected_attributes) { {} }

        def call_operation
          instance.call({})
        end

        include_examples 'should build and insert the entity'
      end

      describe 'with a valid attributes hash with string keys' do
        let(:expected_attributes) { initial_attributes }

        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(initial_attributes)

          instance.call(attributes)
        end

        include_examples 'should build and insert the entity'
      end

      describe 'with a valid attributes hash with symbol keys' do
        let(:expected_attributes) { initial_attributes }

        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(initial_attributes)

          instance.call(attributes)
        end

        include_examples 'should build and insert the entity'
      end

      wrap_context 'when the operation is defined with a contract' do
        let(:contract) { entity_contract }

        describe 'with an invalid attributes hash with string keys' do
          let(:expected_attributes) { invalid_attributes }
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_strings(invalid_attributes)

            instance.call(attributes)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be_a entity_class
            expect(instance.result.value.persisted?).to be false
          end

          it 'should set the attributes', :aggregate_failures do
            entity = call_operation.value

            initial_attributes.each_key do |key|
              expect(entity.send key).to be == expected_attributes[key]
            end
          end

          it { expect { call_operation }.not_to change(collection, :count) }
        end

        describe 'with an invalid attributes hash with symbol keys' do
          let(:expected_attributes) { invalid_attributes }
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_symbols(invalid_attributes)

            instance.call(attributes)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be_a entity_class
            expect(instance.result.value.persisted?).to be false
          end

          it 'should set the attributes', :aggregate_failures do
            entity = call_operation.value

            initial_attributes.each_key do |key|
              expect(entity.send key).to be == expected_attributes[key]
            end
          end

          it { expect { call_operation }.not_to change(collection, :count) }
        end

        describe 'with a valid attributes hash with string keys' do
          let(:expected_attributes) { initial_attributes }

          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_strings(initial_attributes)

            instance.call(attributes)
          end

          include_examples 'should build and insert the entity'
        end

        describe 'with a valid attributes hash with symbol keys' do
          let(:expected_attributes) { initial_attributes }

          def call_operation
            tools      = SleepingKingStudios::Tools::Toolbelt.instance
            attributes = tools.hash.convert_keys_to_symbols(initial_attributes)

            instance.call(attributes)
          end

          include_examples 'should build and insert the entity'
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(0..1).arguments }

    include_examples 'should create the entity'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should create the entity'
    end
  end
end
