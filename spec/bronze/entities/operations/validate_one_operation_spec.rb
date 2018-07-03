# spec/bronze/entities/operations/validate_one_operation_spec.rb

require 'bronze/entities/operations/entity_operation_examples'
require 'bronze/entities/operations/validate_one_operation'

RSpec.xdescribe Bronze::Entities::Operations::ValidateOneOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  include_context 'when the entity class is defined'

  shared_context 'when the operation is defined with a contract' do
    let(:arguments) { [contract] }
  end # shared_context

  shared_context 'when the entity class defines a ::Contract constant' do
    before(:example) do
      entity_class.const_set(:Contract, contract)
    end # before example
  end # shared_context

  shared_context 'when the entity class defines a .contract method' do
    before(:example) do
      defined_contract = contract

      entity_class.define_singleton_method(:contract) { defined_contract }
    end # before example
  end # shared_context

  let(:contract)  { Bronze::Contracts::Contract.new }
  let(:arguments) { [] }
  let(:instance)  { described_class.new(entity_class, *arguments) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  include_examples 'should implement the EntityOperation methods'

  describe '#contract' do
    include_examples 'should have reader', :contract, nil

    wrap_context 'when the operation is defined with a contract' do
      it { expect(instance.contract).to be contract }
    end # wrap_context

    wrap_context 'when the entity class defines a ::Contract constant' do
      it { expect(instance.contract).to be contract }
    end # wrap_context

    wrap_context 'when the entity class defines a .contract method' do
      it { expect(instance.contract).to be contract }
    end # wrap_context
  end # describe

  describe '#execute' do
    describe 'with nil' do
      def execute_operation
        instance.execute(nil)
      end # method execute_operation

      include_examples 'should succeed and clear the errors'

      it 'should set the result to nil' do
        expect(execute_operation.result).to be nil
      end # it
    end # describe

    describe 'with an entity' do
      let(:entity) { entity_class.new(initial_attributes) }

      def execute_operation
        instance.execute(entity)
      end # method execute_operation

      include_examples 'should succeed and clear the errors'

      it 'should set the result to the entity' do
        expect(execute_operation.result).to be entity
      end # it
    end # describe
  end # describe

  wrap_context 'when the operation is defined with a contract' do
    include_examples 'should validate the entity with the contract'
  end # wrap_context

  wrap_context 'when a subclass is defined with the entity class' do
    describe '#contract' do
      include_examples 'should have reader', :contract, nil

      wrap_context 'when the operation is defined with a contract' do
        it { expect(instance.contract).to be contract }
      end # wrap_context

      wrap_context 'when the entity class defines a ::Contract constant' do
        it { expect(instance.contract).to be contract }
      end # wrap_context

      wrap_context 'when the entity class defines a .contract method' do
        it { expect(instance.contract).to be contract }
      end # wrap_context
    end # describe

    describe '#execute' do
      describe 'with nil' do
        def execute_operation
          instance.execute(nil)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to nil' do
          expect(execute_operation.result).to be nil
        end # it
      end # describe

      describe 'with an entity' do
        let(:entity) { entity_class.new(initial_attributes) }

        def execute_operation
          instance.execute(entity)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the entity' do
          expect(execute_operation.result).to be entity
        end # it
      end # describe
    end # describe

    wrap_context 'when the operation is defined with a contract' do
      include_examples 'should validate the entity with the contract'
    end # wrap_context
  end # wrap_context
end # describe
