require 'bronze/entities/operations/build_one_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::BuildOneOperation do
  include Spec::Support::Examples::Entities::EntityOperationExamples

  include_context 'when the entity class is defined'

  subject(:instance) { described_class.new(entity_class: entity_class) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class)
    end
  end

  include_examples 'should implement the EntityOperation methods'

  describe '#call' do
    shared_examples 'should build the entity' do
      describe 'with no arguments' do
        def call_operation
          instance.call
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          instance.call

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end
        end
      end

      describe 'with nil' do
        def call_operation
          instance.call(nil)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end
        end
      end

      describe 'with an empty attributes hash' do
        def call_operation
          instance.call({})
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end
        end
      end

      describe 'with a valid attributes hash with string keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(initial_attributes)

          instance.call(attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end

      describe 'with a valid attributes hash with symbol keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(initial_attributes)

          instance.call(attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(0..1).arguments }

    include_examples 'should build the entity'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should build the entity'
    end
  end
end
