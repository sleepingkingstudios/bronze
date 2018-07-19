require 'bronze/entities/operations/entity_operation_examples'
require 'bronze/entities/operations/validate_one_operation'

RSpec.describe Bronze::Entities::Operations::ValidateOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  shared_context 'when the operation is defined with a contract' do
    let(:contract) { Bronze::Contracts::Contract.new }
  end

  shared_context 'when the entity class defines a ::Contract constant' do
    before(:example) do
      entity_class.const_set(:Contract, contract)
    end
  end

  shared_context 'when the entity class defines a .contract method' do
    before(:example) do
      defined_contract = contract

      entity_class.define_singleton_method(:contract) { defined_contract }
    end
  end

  subject(:instance) { described_class.new(**keywords) }

  let(:contract) { nil }
  let(:keywords) do
    { entity_class: entity_class, contract: contract }
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :contract)
    end
  end

  include_examples 'should implement the EntityOperation methods'

  describe '#contract' do
    include_examples 'should have reader', :contract, nil

    wrap_context 'when the operation is defined with a contract' do
      it { expect(instance.contract).to be contract }
    end

    wrap_context 'when the entity class defines a ::Contract constant' do
      it { expect(instance.contract).to be contract }
    end

    wrap_context 'when the entity class defines a .contract method' do
      it { expect(instance.contract).to be contract }
    end
  end

  describe '#call' do
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

  wrap_context 'when the operation is defined with a contract' do
    include_examples 'should validate the entity with the contract'
  end

  wrap_context 'when a subclass is defined with the entity class' do
    describe '#contract' do
      include_examples 'should have reader', :contract, nil

      wrap_context 'when the operation is defined with a contract' do
        it { expect(instance.contract).to be contract }
      end

      wrap_context 'when the entity class defines a ::Contract constant' do
        it { expect(instance.contract).to be contract }
      end

      wrap_context 'when the entity class defines a .contract method' do
        it { expect(instance.contract).to be contract }
      end
    end

    describe '#call' do
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

    wrap_context 'when the operation is defined with a contract' do
      include_examples 'should validate the entity with the contract'
    end
  end
end
