require 'bronze/entities/operations/find_matching_operation'

require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::FindMatchingOperation do
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
    shared_examples 'should find the entities matching the selector' do
      let(:selector) { {} }
      let(:expected) { collection.matching(selector).to_a }

      include_context 'when the repository has many entities'

      describe 'with no arguments' do
        def call_operation
          instance.call
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the matching entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*expected)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end

      describe 'with :matching => empty selector' do
        def call_operation
          instance.call matching: selector
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the matching entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*expected)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end

      describe 'with :matching => selector matching no entities' do
        let(:selector) { { title: 'Cryptozoology Monthly' } }

        def call_operation
          instance.call matching: selector
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to an empty array' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with :matching => selector matching some entities' do
        let(:selector) { { title: 'The Atlantean Diaspora' } }

        def call_operation
          instance.call matching: selector
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the matching entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*expected)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end

      describe 'with :matching => selector matching all entities' do
        let(:selector) { { volume: { __in: [1, 2, 3] } } }

        def call_operation
          instance.call matching: selector
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the matching entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*expected)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end
    end

    it { expect(instance).to respond_to(:call).with(1).argument }

    include_examples 'should find the entities matching the selector'

    wrap_context 'when a subclass is defined with the entity class' do
      include_examples 'should find the entities matching the selector'
    end
  end
end
