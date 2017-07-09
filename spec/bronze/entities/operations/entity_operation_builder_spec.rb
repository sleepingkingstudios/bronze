# spec/bronze/entities/operations/entity_operation_builder_spec.rb

require 'bronze/entities/entity'
require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/entity_operation_builder'
require 'bronze/operations/operation_builder_examples'

RSpec.describe Bronze::Entities::Operations::EntityOperationBuilder do
  include Spec::Operations::OperationBuilderExamples

  shared_examples 'should define the operation subclasses' do |receiver:|
    it 'should define the operation subclasses', :aggregate_failures do
      module_instance.define_entity_operations

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
      module_instance.define_entity_operations

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

  example_class 'Spec::Book', :base_class => Bronze::Entities::Entity

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }

    describe 'with a block' do
      let(:operation_names) do
        module_instance.send :entity_operation_names
      end # let
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

  describe '#define_entity_operations' do
    let(:operation_names) do
      module_instance.send :entity_operation_names
    end # let

    it 'should define the method' do
      expect(module_instance).
        to respond_to(:define_entity_operations).
        with(0).arguments
    end # it

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
  end # describe

  describe '#entity_operation' do
    shared_examples 'should define the operation subclass' do |receiver:|
      let(:const_name) do
        tools = SleepingKingStudios::Tools::Toolbelt.instance

        tools.string.camelize(operation_name)
      end # let
      let(:qualified_name) do
        "#{module_instance.name}::#{const_name}"
      end # let

      it 'should define the operation subclass' do
        expect(send(receiver)).
          to have_constant(const_name).
          with_value(expected_class)

        subclass = send(receiver).const_get(const_name)

        expect(subclass.name).to be == qualified_name
        expect(subclass.new.entity_class).to be entity_class
      end # it
    end # shared_examples

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

    it 'should define the method' do
      expect(module_instance).
        to respond_to(:entity_operation).
        with(1..2).arguments
    end # it

    describe 'with an entity operation class' do
      before(:example) { module_instance.entity_operation(operation_class) }

      include_examples 'should define the operation subclass',
        :receiver => :module_instance

      include_examples 'should define the operation method',
        :receiver => :module_instance

      include_examples 'should execute the operation',
        :receiver => :module_instance
    end # describe

    describe 'with an operation name and class' do
      let(:operation_name) { :named }

      before(:example) do
        module_instance.entity_operation(operation_name, operation_class)
      end # before example

      include_examples 'should define the operation subclass',
        :receiver => :module_instance

      include_examples 'should define the operation method',
        :receiver => :module_instance

      include_examples 'should execute the operation',
        :receiver => :module_instance
    end # describe

    wrap_context 'when the builder is extended in a class' do
      describe 'with an entity operation class' do
        before(:example) { module_instance.entity_operation(operation_class) }

        include_examples 'should define the operation subclass',
          :receiver => :described_class

        include_examples 'should define the operation method',
          :receiver => :described_class

        include_examples 'should execute the operation',
          :receiver => :described_class
      end # describe

      describe 'with an operation name and class' do
        let(:operation_name) { :named }

        before(:example) do
          module_instance.entity_operation(operation_name, operation_class)
        end # before example

        include_examples 'should define the operation subclass',
          :receiver => :described_class

        include_examples 'should define the operation method',
          :receiver => :described_class

        include_examples 'should execute the operation',
          :receiver => :described_class
      end # describe
    end # wrap_context
  end # describe
end # describe
