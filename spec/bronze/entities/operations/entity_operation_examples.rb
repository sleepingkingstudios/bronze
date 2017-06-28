# spec/bronze/entities/operations/entity_operation_examples.rb

module Spec::Entities
  module Operations; end
end # module

module Spec::Entities::Operations::EntityOperationExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_context 'when the entity class is defined' do
    options = { :base_class => Bronze::Entities::Entity }
    example_class 'Spec::Book', options do |klass|
      klass.attribute :title,      String
      klass.attribute :author,     String
      klass.attribute :page_count, Integer
    end # example_class

    let(:entity_class) { Spec::Book }

    let(:initial_attributes) do
      {
        :title      => 'At The Earth\'s Core',
        :author     => 'Edgar Rice Burroughs',
        :page_count => 256
      } # end hash
    end # let
    let(:valid_attributes)   { { :title => 'Pellucidar', :page_count => 320 } }
    let(:invalid_attributes) { { :title => nil, :publisher => 'Tor' } }
  end # shared_context

  shared_context 'when a subclass is defined with the entity class' do
    let(:described_class) { super().subclass(entity_class) }
    let(:instance)        { described_class.new(*arguments) }
  end # shared_context

  shared_examples 'should succeed and clear the errors' do
    it 'should succeed and clear the errors' do
      execute_operation

      expect(instance.success?).to be true
      expect(instance.halted?).to be false
      expect(instance.errors.empty?).to be true
    end # it
  end # shared_examples

  shared_examples 'should implement the EntityOperation methods' do
    describe '::subclass' do
      it { expect(described_class).to respond_to(:subclass).with(1).argument }

      it 'should return a subclass of the operation class' do
        subclass = described_class.subclass(entity_class)

        expect(subclass).to be_a Class
        expect(subclass.superclass).to be described_class
        expect(subclass).to be_constructible.with(arguments.count).arguments
        expect(subclass.new.entity_class).to be entity_class
      end # it
    end # describe

    describe '#entity_class' do
      include_examples 'should have reader',
        :entity_class,
        ->() { entity_class }
    end # describe
  end # shared_examples

  shared_examples 'should assign the attributes to the entity' do
    describe '#execute' do
      let(:expected_attributes) do
        initial_attributes.dup.tap do |hsh|
          valid_attributes.each do |key, value|
            hsh[key] = value
          end # each
        end # initial_attributes
      end # let
      let(:entity) { entity_class.new(initial_attributes) }

      it { expect(instance).to respond_to(:execute).with(2).arguments }

      describe 'with a valid attributes hash with string keys' do
        def execute_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(valid_attributes)

          instance.execute(entity, attributes)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be entity
        end # it

        it 'should update the attributes', :aggregate_failures do
          execute_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end # each
        end # it
      end # describe

      describe 'with a valid attributes hash with symbol keys' do
        def execute_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(valid_attributes)

          instance.execute(entity, attributes)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be entity
        end # it

        it 'should update the attributes', :aggregate_failures do
          execute_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end # each
        end # it
      end # describe
    end # describe
  end # shared_examples

  shared_examples 'should build the entity' do
    describe '#execute' do
      it { expect(instance).to respond_to(:execute).with(1).argument }

      describe 'with a valid attributes hash with string keys' do
        def execute_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(initial_attributes)

          instance.execute(attributes)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be_a entity_class
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end # each
        end # it
      end # describe

      describe 'with a valid attributes hash with symbol keys' do
        def execute_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(initial_attributes)

          instance.execute(attributes)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be_a entity_class
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end # each
        end # it
      end # describe
    end # describe
  end # shared_examples
end # module
