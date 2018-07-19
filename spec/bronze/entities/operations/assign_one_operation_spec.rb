require 'bronze/entities/operations/assign_one_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::AssignOneOperation do
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
    shared_examples 'should assign the attributes to the entity' do
      let(:expected_attributes) do
        initial_attributes.dup.tap do |hsh|
          valid_attributes.each do |key, value|
            hsh[key] = value
          end
        end
      end
      let(:entity) { entity_class.new(initial_attributes) }

      describe 'with a valid attributes hash with string keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(valid_attributes)

          instance.call(entity, attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
        end

        it 'should update the attributes', :aggregate_failures do
          call_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end

      describe 'with a valid attributes hash with symbol keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(valid_attributes)

          instance.call(entity, attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
        end

        it 'should update the attributes', :aggregate_failures do
          call_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(2).arguments }

    include_examples 'should assign the attributes to the entity'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should assign the attributes to the entity'
    end
  end
end
