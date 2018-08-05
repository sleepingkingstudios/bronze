require 'bronze/entities/operations/insert_one_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::InsertOneOperation do
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
    shared_examples 'should insert the entity into the collection' do
      describe 'with nil' do
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   =>
              Bronze::Collections::Collection::Errors.primary_key_missing,
            :params => { :key => :id }
          }
        end

        def call_operation
          instance.call(nil)
        end

        include_examples 'should fail and set the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end

        it { expect { call_operation }.not_to change(collection, :count) }
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
          expect(instance.result.value).to be_a entity_class
          expect(instance.result.value.persisted?).to be true
        end

        it { expect { call_operation }.to change(collection, :count).by(1) }
      end
    end

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should insert the entity into the collection'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should insert the entity into the collection'
    end
  end
end
