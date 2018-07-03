require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/entity_operation_examples'

require 'cuprum/operation'

require 'support/example_entity'

RSpec.describe Bronze::Entities::Operations::EntityOperation do
  include Spec::Entities::Operations::EntityOperationExamples

  let(:described_class) do
    Class.new(Cuprum::Operation) do
      include Bronze::Entities::Operations::EntityOperation
    end
  end
  let(:entity_class) { Spec::ExampleEntity }
  let(:arguments)    { [] }
  let(:instance) do
    described_class.new(*arguments, entity_class: entity_class)
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with_unlimited_arguments
        .and_keywords(:entity_class)
        .and_any_keywords
    end
  end

  include_examples 'should implement the EntityOperation methods'

  describe '::subclass' do
    context 'when the base class is a defined operation class' do
      base_class =
        Class.new(Cuprum::Operation) do
          include Bronze::Entities::Operations::EntityOperation
        end
      options    = { :base_class => base_class }
      example_class 'Spec::Operations::EntityNameOperation', options do |klass|
        klass.send :define_method, :initialize do |format = '%s', entity_class:|
          super(entity_class: entity_class)

          @format = format
        end

        klass.send :define_method, :process do
          Kernel.format(@format, entity_class.name)
        end
      end

      let(:described_class) { Spec::Operations::EntityNameOperation }
      let(:expected)        { 'Name: Spec::ExampleEntity' }

      it { expect(described_class).to respond_to(:subclass).with(1).argument }

      it 'should return a subclass of the operation class' do
        subclass = described_class.subclass(entity_class)
        instance = subclass.new('Name: %s')

        expect(subclass).to be_a Class
        expect(subclass.superclass).to be described_class
        expect(subclass.ancestors).
          to include Bronze::Entities::Operations::EntityOperation
        expect(subclass).to be_constructible.with(0..1).arguments
        expect(instance.entity_class).to be entity_class
        expect(instance.call.value).to be == expected
      end
    end
  end
end
