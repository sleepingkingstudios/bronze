require 'bronze/entities/operations/find_many_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::FindManyOperation do
  include Spec::Support::Examples::Entities::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  subject(:instance) do
    described_class.new(entity_class: entity_class, **keywords)
  end

  let(:transform) { nil }
  let(:defaults) do
    {
      repository: Patina::Collections::Simple::Repository.new,
      transform:  Bronze::Transforms::IdentityTransform.new
    }
  end
  let(:keywords) { { repository: repository, transform: transform } }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :repository, :transform)
    end
  end

  include_examples 'should implement the EntityOperation methods'

  include_examples 'should implement the PersistenceOperation methods'

  describe '#call' do
    shared_examples 'should find the entities with given primary keys' do
      include_context 'when the repository has many entities'

      describe 'with no arguments' do
        def call_operation
          instance.call
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with nil' do
        def call_operation
          instance.call(nil)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 1
          expect(instance.errors).to include(
            :type   => error_context.record_not_found,
            :path   => [plural_entity_name.intern],
            :params => { :id => nil }
          )
        }

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with an invalid entity id' do
        let(:entity_id) { entity_class.new.id }

        def call_operation
          instance.call(entity_id)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 1
          expect(instance.errors).to include(
            :type   => error_context.record_not_found,
            :path   => [plural_entity_name.intern],
            :params => { :id => entity_id }
          )
        }

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with a valid entity id' do
        let(:entity)    { collection.limit(1).one }
        let(:entity_id) { entity.id }

        def call_operation
          instance.call(entity_id)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly entity
        end
      end

      describe 'with an empty array' do
        def call_operation
          instance.call([])
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with an array of invalid entity ids' do
        let(:entity_ids) { Array.new(3) { entity_class.new.id } }

        def call_operation
          instance.call(entity_ids)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 3

          entity_ids.each do |entity_id|
            expect(instance.errors).to include(
              :type   => error_context.record_not_found,
              :path   => [plural_entity_name.intern],
              :params => { :id => entity_id }
            )
          end
        }

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with an array of mixed valid and invalid entity ids' do
        let(:invalid_entity_ids) { Array.new(3) { entity_class.new.id } }
        let(:entities)           { collection.limit(3).to_a }
        let(:valid_entity_ids)   { entities.map(&:id) }
        let(:entity_ids)         { [*invalid_entity_ids, *valid_entity_ids] }

        def call_operation
          instance.call(entity_ids)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 3

          invalid_entity_ids.each do |entity_id|
            expect(instance.errors).to include(
              :type   => error_context.record_not_found,
              :path   => [plural_entity_name.intern],
              :params => { :id => entity_id }
            )
          end
        }

        it 'should set the result to the found entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*entities)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end

      describe 'with an array of valid entity ids' do
        let(:entities)   { collection.limit(3).to_a }
        let(:entity_ids) { entities.map(&:id) }

        def call_operation
          instance.call(entity_ids)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the found entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*entities)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should find the entities with given primary keys'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should find the entities with given primary keys'
    end
  end
end
