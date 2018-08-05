require 'bronze/entities/operations/find_one_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::FindOneOperation do
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
    shared_examples 'should find the entity with the given primary key' do
      include_context 'when the repository has many entities'

      describe 'with nil' do
        def call_operation
          instance.call(nil)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 1
          expect(instance.errors).to include(
            :type   => error_context.record_not_found,
            :path   => [entity_name.intern],
            :params => { :id => nil }
          )
        }

        it 'should set the result to nil' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
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
            :path   => [entity_name.intern],
            :params => { :id => entity_id }
          )
        }

        it 'should set the result to nil' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end
      end

      describe 'with a valid entity id' do
        let(:entity)    { collection.limit(1).one }
        let(:entity_id) { entity.id }

        def call_operation
          instance.call(entity_id)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the found entity' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
          expect(instance.result.value.persisted?).to be true
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should find the entity with the given primary key'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should find the entity with the given primary key'
    end
  end
end
