require 'bronze/entities/operations/validate_one_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::ValidateOneOperation do
  include Spec::Support::Examples::Entities::EntityOperationExamples

  include_context 'when the entity class is defined'

  subject(:instance) do
    described_class.new(entity_class: entity_class, **keywords)
  end

  let(:contract) { nil }
  let(:keywords) { { contract: contract } }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :contract)
    end
  end

  include_examples 'should implement the ContractOperation methods'

  include_examples 'should implement the EntityOperation methods'

  describe '#call' do
    shared_examples 'should validate the entity with the contract' do
      context 'when the contract has no constraints' do
        let(:contract) { Bronze::Contracts::Contract.new }

        describe 'with nil' do
          def call_operation
            instance.call(nil)
          end

          include_examples 'should succeed and clear the errors'

          it 'should set the result to nil' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be nil
          end
        end

        describe 'with an entity' do
          let(:entity) { entity_class.new(initial_attributes) }

          def call_operation
            instance.call(entity)
          end

          include_examples 'should succeed and clear the errors'

          it 'should set the result to the entity' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be == entity
          end
        end
      end

      context 'when the contract validates the entity properties' do
        let(:contract) { entity_contract }

        describe 'with nil' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          def call_operation
            instance.call(nil)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result to nil' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be nil
          end
        end

        describe 'with an invalid entity' do
          let(:entity) { entity_class.new(initial_attributes) }
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          before(:example) do
            entity.assign(invalid_attributes)
          end

          def call_operation
            instance.call(entity)
          end

          include_examples 'should fail and set the errors'

          it 'should set the result to the entity' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be == entity
          end
        end

        describe 'with a valid entity' do
          let(:entity) { entity_class.new(initial_attributes) }

          def call_operation
            instance.call(entity)
          end

          include_examples 'should succeed and clear the errors'

          it 'should set the result to the entity' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be == entity
          end
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(1).argument }

    describe 'with nil' do
      def call_operation
        instance.call(nil)
      end

      include_examples 'should succeed and clear the errors'

      it 'should set the result to nil' do
        call_operation

        expect(instance.result).to be_a Cuprum::Result
        expect(instance.result.value).to be nil
      end
    end

    describe 'with an entity' do
      let(:entity) { entity_class.new(initial_attributes) }

      def call_operation
        instance.call(entity)
      end

      include_examples 'should succeed and clear the errors'

      it 'should set the result to the entity' do
        call_operation

        expect(instance.result).to be_a Cuprum::Result
        expect(instance.result.value).to be == entity
      end
    end

    include_examples 'should validate the entity with the contract'

    wrap_context 'when the operation is defined with a contract' do
      describe 'with nil' do
        def call_operation
          instance.call(nil)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to nil' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end
      end

      describe 'with an entity' do
        let(:entity) { entity_class.new(initial_attributes) }

        def call_operation
          instance.call(entity)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the entity' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
        end
      end

      include_examples 'should validate the entity with the contract'
    end
  end
end
