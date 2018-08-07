require 'bronze/operations/update_one_operation'

require 'support/examples/entity_operation_examples'

RSpec.describe Bronze::Operations::UpdateOneOperation do
  include Spec::Support::Examples::EntityOperationExamples

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
    shared_examples 'should update the entity in the collection' do
      include_context 'when the repository has many entities'

      let(:expected_attributes) do
        entity.attributes.tap do |hsh|
          valid_attributes.each do |key, value|
            hsh[key] = value
          end
        end
      end

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

        it 'should set the result to nil' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
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
          instance.call(entity)
        end

        include_examples 'should fail and set the errors'

        it 'should set the result to the entity' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
        end
      end

      describe 'with an entity that is in the collection' do
        let(:entity) { collection.limit(1).one }

        before(:example) { entity.assign(valid_attributes) }

        def call_operation
          instance.call(entity)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the entity' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
          expect(instance.result.value.attributes_changed?).to be false
        end

        it 'should update the attributes in the collection' do
          call_operation

          persisted = collection.find(entity.id)

          expected_attributes.each do |key, value|
            expect(persisted.send key).to be == value
          end
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should update the entity in the collection'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should update the entity in the collection'
    end
  end
end
