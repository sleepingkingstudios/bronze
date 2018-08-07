require 'bronze/operations/entity_operation_factory'

require 'support/examples/entity_operation_examples'

RSpec.describe Bronze::Operations::EntityOperationFactory do
  include Spec::Support::Examples::EntityOperationExamples

  include_context 'when the entity class is defined'

  include_context 'when the repository is defined'

  shared_context 'when the factory has a contract' do
    let(:factory_contract) { Bronze::Contracts::Contract.new }
  end

  shared_context 'when the factory has a repository' do
    let(:factory_repository) { Patina::Collections::Simple::Repository.new }
  end

  shared_context 'when the factory has a transform' do
    let(:factory_transform) { Bronze::Transforms::IdentityTransform.new }
  end

  shared_context 'when the factory has configuration options' do
    include_context 'when the factory has a contract'
    include_context 'when the factory has a repository'
    include_context 'when the factory has a transform'
  end

  shared_examples 'should define a contract operation' do |command_name|
    tools        = SleepingKingStudios::Tools::Toolbelt.instance
    const_name   = tools.string.camelize(command_name).intern
    command_name = tools.string.underscore(command_name).intern

    describe "::#{const_name}" do
      let(:operation_class) do
        Bronze::Operations.const_get("#{const_name}Operation")
      end

      it 'should define the constant' do
        expect(instance)
          .to have_constant(const_name)
          .with_value(an_instance_of Class)
      end

      it 'should define the operation subclass' do
        expect(instance.const_get(const_name).superclass).to be operation_class
      end

      describe 'with no arguments' do
        let(:operation) { instance.const_get(const_name).new }

        it { expect(operation.entity_class).to be entity_class }

        it { expect(operation.contract).to be nil }

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.contract).to be factory_contract }
        end
      end

      describe 'with optional keywords' do
        let(:contract) { Bronze::Contracts::Contract.new }
        let(:operation) do
          instance.const_get(const_name).new(contract: contract)
        end

        it { expect(operation.entity_class).to be entity_class }

        it { expect(operation.contract).to be contract }

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.contract).to be contract }
        end
      end
    end

    describe '#command?' do
      it { expect(instance.command? command_name).to be true }
    end

    describe '#commands' do
      it { expect(instance.commands).to include command_name }
    end

    describe "##{command_name}" do
      it { expect(instance).to respond_to(command_name).with(0).arguments }

      describe 'with no arguments' do
        let(:operation) { instance.send(command_name) }

        it { expect(operation).to be_a instance.const_get(const_name) }

        it { expect(operation.entity_class).to be entity_class }

        it { expect(operation.contract).to be nil }

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.contract).to be factory_contract }
        end
      end

      describe 'with optional keywords' do
        let(:contract)  { Bronze::Contracts::Contract.new }
        let(:operation) { instance.send(command_name, contract: contract) }

        it { expect(operation).to be_a instance.const_get(const_name) }

        it { expect(operation.entity_class).to be entity_class }

        it { expect(operation.contract).to be contract }

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.contract).to be contract }
        end
      end
    end
  end

  shared_examples 'should define an entity operation' do |command_name|
    tools        = SleepingKingStudios::Tools::Toolbelt.instance
    const_name   = tools.string.camelize(command_name).intern
    command_name = tools.string.underscore(command_name).intern

    describe "::#{const_name}" do
      let(:operation_class) do
        Bronze::Operations.const_get("#{const_name}Operation")
      end

      it 'should define the constant' do
        expect(instance)
          .to have_constant(const_name)
          .with_value(an_instance_of Class)
      end

      it 'should define the operation subclass' do
        expect(instance.const_get(const_name).superclass).to be operation_class
      end

      it 'should set the entity class' do
        expect(instance.const_get(const_name).new.entity_class)
          .to be entity_class
      end
    end

    describe '#command?' do
      it { expect(instance.command? command_name).to be true }
    end

    describe '#commands' do
      it { expect(instance.commands).to include command_name }
    end

    describe "##{command_name}" do
      let(:operation) { instance.send(command_name) }

      it { expect(instance).to respond_to(command_name).with(0).arguments }

      it { expect(operation).to be_a instance.const_get(const_name) }

      it { expect(operation.entity_class).to be entity_class }
    end
  end

  shared_examples 'should define a persistence operation' do |command_name|
    tools        = SleepingKingStudios::Tools::Toolbelt.instance
    const_name   = tools.string.camelize(command_name).intern
    command_name = tools.string.underscore(command_name).intern

    describe "::#{const_name}" do
      let(:operation_class) do
        Bronze::Operations.const_get("#{const_name}Operation")
      end

      it 'should define the constant' do
        expect(instance)
          .to have_constant(const_name)
          .with_value(an_instance_of Class)
      end

      it 'should define the operation subclass' do
        expect(instance.const_get(const_name).superclass).to be operation_class
      end

      describe 'with no arguments' do
        let(:operation) { instance.const_get(const_name).new }

        it 'should raise an error' do
          expect { instance.const_get(const_name).new }
            .to raise_error ArgumentError
        end

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.repository).to be factory_repository }

          it { expect(operation.transform).to be factory_transform }
        end
      end

      describe 'with required keywords' do
        let(:operation) do
          instance.const_get(const_name).new(repository: repository)
        end

        it { expect(operation.entity_class).to be entity_class }

        it { expect(operation.repository).to be repository }

        it 'should have the default transform' do
          expect(operation.transform)
            .to be_a Bronze::Entities::Transforms::EntityTransform
        end

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.repository).to be repository }

          it { expect(operation.transform).to be factory_transform }
        end
      end
    end

    describe '#command?' do
      it { expect(instance.command? command_name).to be true }
    end

    describe '#commands' do
      it { expect(instance.commands).to include command_name }
    end

    describe "##{command_name}" do
      it { expect(instance).to respond_to(:delete_one).with(0..1).arguments }

      describe 'with no arguments' do
        let(:operation) { instance.send(command_name) }

        it 'should raise an error' do
          expect { instance.send(command_name) }.to raise_error ArgumentError
        end

        wrap_context 'when the factory has configuration options' do
          it { expect(operation).to be_a instance.const_get(const_name) }

          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.repository).to be factory_repository }

          it { expect(operation.transform).to be factory_transform }
        end
      end

      describe 'with required keywords' do
        let(:operation) { instance.send(command_name, repository: repository) }

        it { expect(operation).to be_a instance.const_get(const_name) }

        it { expect(operation.entity_class).to be entity_class }

        it { expect(operation.repository).to be repository }

        it 'should have the default transform' do
          expect(operation.transform)
            .to be_a Bronze::Entities::Transforms::EntityTransform
        end

        wrap_context 'when the factory has configuration options' do
          it { expect(operation.entity_class).to be entity_class }

          it { expect(operation.repository).to be repository }

          it { expect(operation.transform).to be factory_transform }
        end
      end
    end
  end

  subject(:instance) do
    described_class.new(
      entity_class,
      contract:   factory_contract,
      repository: factory_repository,
      transform:  factory_transform
    )
  end

  let(:factory_contract)   { nil }
  let(:factory_repository) { nil }
  let(:factory_transform)  { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:contract, :repository, :transform)
    end
  end

  include_examples 'should define an entity operation',     :assign_one

  include_examples 'should define an entity operation',     :build_one

  include_examples 'should define a persistence operation', :delete_one

  include_examples 'should define a persistence operation', :find_many

  include_examples 'should define a persistence operation', :find_matching

  include_examples 'should define a persistence operation', :find_one

  include_examples 'should define a persistence operation', :insert_one

  include_examples 'should define a persistence operation', :update_one

  include_examples 'should define a contract operation',    :validate_one

  describe '#command?' do
    it { expect(instance).to respond_to(:command?).with(1).argument }

    it { expect(instance.command? :defenestrate).to be false }
  end

  describe '#commands' do
    include_examples 'should have reader',
      :commands,
      -> { an_instance_of Array }

    it { expect(instance.commands).not_to include :defenestrate }
  end

  describe '#contract' do
    include_examples 'should have reader', :contract, nil

    wrap_context 'when the factory has a contract' do
      it { expect(instance.contract).to be factory_contract }
    end
  end

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, -> { entity_class }
  end

  describe '#repository' do
    include_examples 'should have reader', :repository, nil

    wrap_context 'when the factory has a repository' do
      it { expect(instance.repository).to be factory_repository }
    end
  end

  describe '#transform' do
    include_examples 'should have reader', :transform, nil

    wrap_context 'when the factory has a transform' do
      it { expect(instance.transform).to be factory_transform }
    end
  end
end
