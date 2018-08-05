require 'bronze/entities/operations/base_operation'

require 'support/example_entity'
require 'support/examples/entities/entity_operation_examples'

RSpec.describe Bronze::Entities::Operations::BaseOperation do
  include Spec::Support::Examples::Entities::EntityOperationExamples

  subject(:instance) { described_class.new(entity_class: entity_class) }

  let(:entity_class) { Spec::ExampleEntity }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .and_keywords(:entity_class)
        .and_any_keywords
    end

    describe 'with arbitrary keywords' do
      let(:keywords) do
        {
          contract:   Bronze::Contracts::Contract.new,
          repository: Patina::Collections::Simple::Repository.new,
          transform:  Bronze::Transforms::IdentityTransform.new
        }
      end

      it 'should not raise an error' do
        expect { described_class.new(entity_class: entity_class, **keywords) }
          .not_to raise_error
      end

      it 'should set the entity class' do
        operation = described_class.new(entity_class: entity_class, **keywords)

        expect(operation.entity_class).to be entity_class
      end
    end
  end

  describe '::subclass' do
    let(:defaults) { defined?(super()) ? super() : {} }
    let(:keywords) { defined?(super()) ? super() : {} }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:subclass)
        .with(1).argument
        .and_any_keywords
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.subclass(nil) }
          .to raise_error ArgumentError, 'must specify an entity class'
      end
    end

    describe 'with an entity class' do
      let(:subclass) { described_class.subclass(entity_class) }
      let(:instance) { subclass.new(**keywords) }

      it { expect(subclass).to be_a Class }

      it { expect(subclass.superclass).to be described_class }

      it { expect(instance.entity_class).to be entity_class }

      it 'should pass through the keywords', :aggregate_failures do
        keywords.each do |key, value|
          expect(instance.send key).to be == value
        end
      end
    end

    describe 'with an entity class and options' do
      let(:subclass) { described_class.subclass(entity_class, **defaults) }

      it { expect(subclass).to be_a Class }

      it { expect(subclass.superclass).to be described_class }

      describe 'with the default options' do
        let(:keywords) { super().reject { |k, _| defaults.include?(k) } }
        let(:instance) { subclass.new(**keywords) }

        it { expect(instance.entity_class).to be entity_class }

        it 'should apply the default options', :aggregate_failures do
          defaults.each do |key, value|
            expect(instance.send key).to be == value
          end
        end

        it 'should pass through the keywords', :aggregate_failures do
          keywords.each do |key, value|
            expect(instance.send key).to be == value
          end
        end
      end

      describe 'with all keywords specified' do
        let(:instance) { subclass.new(**keywords) }

        it { expect(instance.entity_class).to be entity_class }

        it 'should pass through the keywords', :aggregate_failures do
          keywords.each do |key, value|
            expect(instance.send key).to be == value
          end
        end
      end
    end
  end

  include_examples 'should implement the BaseOperation methods'

  include_examples 'should implement the EntityOperation methods'

  describe '#errors' do
    context 'when the operation has been called' do
      before(:example) do
        allow(instance).to receive(:process)
      end

      it 'should return the result errors object' do
        result = instance.call

        expect(instance.errors).to be_a Bronze::Errors
        expect(instance.errors).to be result.errors
      end
    end
  end
end
