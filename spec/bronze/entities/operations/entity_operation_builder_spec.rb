# spec/bronze/entities/operations/entity_operation_builder_spec.rb

require 'bronze/entities/entity'
require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/entity_operation_builder'
require 'bronze/operations/operation_builder_examples'

RSpec.describe Bronze::Entities::Operations::EntityOperationBuilder do
  include Bronze::Operations::OperationBuilderExamples

  shared_examples 'should define the operation subclasses' do |receiver:|
    it 'should define the operation subclasses', :aggregate_failures do
      tools = SleepingKingStudios::Tools::Toolbelt.instance

      operation_names.each do |operation_name|
        const_name     = tools.string.camelize(operation_name)
        qualified_name =
          "Bronze::Entities::Operations::#{const_name}Operation"
        base_class     = Object.const_get(qualified_name)

        expect(send(receiver)).to have_constant(const_name)

        subclass = send(receiver).const_get(const_name)

        expect(subclass).to be_a Class
        expect(subclass).to be < base_class
      end # each
    end # it
  end # shared_examples

  shared_examples 'should define the operation methods' do |receiver:|
    it 'should define the operation methods', :aggregate_failures do
      operation_names.each do |method_name|
        expect(send(receiver)).to respond_to(method_name)
      end # each
    end # it
  end # shared_examples

  let(:entity_class) { Spec::Book }
  let(:module_instance) do
    Bronze::Entities::Operations::EntityOperationBuilder.new(entity_class).
      tap do |mod|
        %w(name inspect to_s).each do |method|
          allow(mod).to receive(method).and_return('Spec::Book::Operations')
        end # each
      end # tap
  end # let
  let(:operation_names) do
    [
      :assign_and_update_one,
      :assign_one,
      :build_and_insert_one,
      :build_one,
      :delete_one,
      :find_many,
      :find_matching,
      :find_one,
      :insert_one,
      :insert_one_without_validation,
      :update_one,
      :update_one_without_validation,
      :validate_one,
      :validate_one_uniqueness
    ] # end names
  end # let

  example_class 'Spec::Book', :base_class => Bronze::Entities::Entity

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }

    describe 'with a block' do
      let(:module_instance) do
        # rubocop:disable Metrics/LineLength, Style/MultilineBlockChain
        Bronze::Entities::Operations::EntityOperationBuilder.new(entity_class) do
          define_entity_operations
        end. # module
          tap do |mod|
            %w(name inspect to_s).each do |method|
              allow(mod).to receive(method).and_return('Spec::Book::Operations')
            end # each
          end # tap
        # rubocop:enable Metrics/LineLength, Style/MultilineBlockChain
      end # let

      include_examples 'should define the operation subclasses',
        :receiver => :module_instance

      include_examples 'should define the operation methods',
        :receiver => :module_instance
    end # describe
  end # describe

  include_examples 'should implement the OperationBuilder methods'

  include_examples 'should implement the OperationClassBuilder methods'

  describe '#define_entity_operations' do
    it 'should define the method' do
      expect(module_instance).
        to respond_to(:define_entity_operations).
        with(0).arguments
    end # it

    context 'when the entity operations are defined' do
      before(:example) { module_instance.define_entity_operations }

      include_examples 'should define the operation subclasses',
        :receiver => :module_instance

      include_examples 'should define the operation methods',
        :receiver => :module_instance

      wrap_context 'when the builder is extended in a class' do
        include_examples 'should define the operation subclasses',
          :receiver => :described_class

        include_examples 'should define the operation methods',
          :receiver => :described_class
      end # wrap_context
    end # context
  end # describe

  describe '#entity_class' do
    let(:instance) { module_instance }

    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe

  describe '#name' do
    context 'when the module is anonymous' do
      let(:expected) do
        "#{entity_class.name.gsub('::', '_')}_OperationBuilder"
      end # let
      let(:module_instance) do
        Bronze::Entities::Operations::EntityOperationBuilder.new(entity_class)
      end # let

      it { expect(module_instance.name).to be == expected }
    end # context

    context 'when the module has a name' do
      before(:example) do
        class Spec::Book
          Operations =
            Bronze::Entities::Operations::EntityOperationBuilder.new(self)
        end # class
      end # before example

      let(:expected)        { 'Spec::Book::Operations' }
      let(:module_instance) { Spec::Book::Operations }

      it { expect(module_instance.name).to be == expected }
    end # context
  end # describe

  describe '#operation' do
    let(:operation_class) do
      # rubocop:disable Style/MultilineBlockChain
      Class.new(Bronze::Operations::Operation) do
        include Bronze::Entities::Operations::EntityOperation

        def self.name
          'CustomOperation'
        end # class method name

        def process *_args
          yield if block_given?
        end # method process
      end. # class
        tap do |klass|
          allow(klass).
            to receive(:subclass).
            with(entity_class).
            and_return(klass.subclass entity_class)
        end # tap
      # rubocop:enable Style/MultilineBlockChain
    end # let
    let(:expected_class) { operation_class.subclass(entity_class) }
    let(:operation_name) { 'custom' }

    describe 'with an entity operation class' do
      before(:example) { module_instance.operation(operation_class) }

      include_examples 'should define the operation subclass',
        lambda { |subclass|
          expect(subclass.new.entity_class).to be entity_class
        }, # end lambda
        :receiver => :module_instance

      include_examples 'should define the operation method',
        :receiver => :module_instance

      include_examples 'should build the operation',
        :receiver => :module_instance
    end # describe

    describe 'with an operation name and class' do
      let(:operation_name) { :named }

      before(:example) do
        module_instance.operation(operation_name, operation_class)
      end # before example

      include_examples 'should define the operation subclass',
        lambda { |subclass|
          expect(subclass.new.entity_class).to be entity_class
        }, # end lambda
        :receiver => :module_instance

      include_examples 'should define the operation method',
        :receiver => :module_instance

      include_examples 'should build the operation',
        :receiver => :module_instance
    end # describe

    wrap_context 'when the builder is extended in a class' do
      describe 'with an entity operation class' do
        before(:example) { module_instance.operation(operation_class) }

        include_examples 'should define the operation subclass',
          lambda { |subclass|
            expect(subclass.new.entity_class).to be entity_class
          }, # end lambda
          :receiver => :described_class

        include_examples 'should define the operation method',
          :receiver => :described_class

        include_examples 'should build the operation',
          :receiver => :described_class
      end # describe

      describe 'with an operation name and class' do
        let(:operation_name) { :named }

        before(:example) do
          module_instance.operation(operation_name, operation_class)
        end # before example

        include_examples 'should define the operation subclass',
          lambda { |subclass|
            expect(subclass.new.entity_class).to be entity_class
          }, # end lambda
          :receiver => :described_class

        include_examples 'should define the operation method',
          :receiver => :described_class

        include_examples 'should build the operation',
          :receiver => :described_class
      end # describe
    end # wrap_context
  end # describe
end # describe
