require 'bronze/contracts/contract'
require 'bronze/entities/entity'
require 'bronze/transforms/identity_transform'

require 'patina/collections/simple/repository'

module Spec::Entities
  module Operations; end
end

module Spec::Entities::Operations::EntityOperationExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_context 'when the entity class is defined' do
    options = { :base_class => Bronze::Entities::Entity }
    example_class 'Spec::Periodical', options do |klass|
      klass.attribute :title,  String
      klass.attribute :volume, Integer
    end

    let(:entity_class)       { Spec::Periodical }
    let(:entity_name)        { 'periodical' }
    let(:plural_entity_name) { 'periodicals' }

    let(:initial_attributes) do
      {
        :title  => 'Crystal Healing Digest',
        :volume => 7
      }
    end
    let(:valid_attributes)   { { :title => 'Cryptozoology Monthly' } }
    let(:invalid_attributes) { { :title => nil, :publisher => 'Bigfoot' } }
    let(:empty_attributes) do
      {
        :title  => nil,
        :volume => nil
      }
    end

    let(:entity_contract) do
      Bronze::Contracts::Contract.new.tap do |contract|
        contract.constrain :title, :present => true
      end
    end
  end

  shared_context 'when the repository is defined' do
    let(:repository) { Patina::Collections::Simple::Repository.new }
    let(:collection) { repository.collection(entity_class) }
  end

  shared_context 'when the repository has many entities' do
    before(:example) do
      [
        'Astrology Today',
        'Journal of Applied Phrenology',
        'The Atlantean Diaspora'
      ].
        each do |title|
          1.upto(3) do |volume|
            attributes =
              initial_attributes.merge(:title => title, :volume => volume)
            entity     = entity_class.new(attributes)

            collection.insert(entity)
          end
        end
    end
  end

  shared_context 'when a subclass is defined with the entity class' do
    let(:described_class) { super().subclass(entity_class) }
    let(:arguments)       { defined?(super()) ? super() : [] }
    let(:keywords)        { defined?(super()) ? super() : {} }
    let(:instance)        { described_class.new(*arguments, **keywords) }
  end

  shared_examples 'should succeed and clear the errors' do
    it 'should succeed and clear the errors' do
      call_operation

      expect(instance.success?).to be true
      expect(instance.halted?).to be false
      expect(instance.errors.empty?).to be true
    end
  end

  shared_examples 'should fail and set the errors' do |proc = nil|
    it 'should fail and set the errors' do
      call_operation

      expect(instance.failure?).to be true
      expect(instance.halted?).to be false

      error_expectation = defined?(expected_error) ? expected_error : nil

      if error_expectation.nil?
        expect(instance.errors).not_to be_empty
      elsif error_expectation.is_a?(Hash)
        expect(instance.errors.each.any? { |err| error_expectation <= err }).
          to be true
      else
        expect(instance.errors).to include error_expectation
      end

      instance_exec(&proc) unless proc.nil?
    end
  end

  shared_examples 'should implement the EntityOperation methods' do
    describe '::subclass' do
      let(:arguments) { defined?(super()) ? super() : [] }
      let(:keywords)  { defined?(super()) ? super() : {} }

      it { expect(described_class).to respond_to(:subclass).with(1).argument }

      it 'should return a subclass of the operation class' do
        subclass = described_class.subclass(entity_class)

        expect(subclass).to be_a Class
        expect(subclass.superclass).to be described_class
        expect(subclass)
          .to be_constructible
          .with(arguments.count).arguments
          .and_keywords(*keywords.keys)
        expect(subclass.new(**keywords).entity_class).to be entity_class
      end
    end

    describe '#entity_class' do
      include_examples 'should have reader',
        :entity_class,
        ->() { entity_class }
    end
  end

  shared_examples 'should implement the PersistenceOperation methods' do
    describe '#collection' do
      include_examples 'should have reader', :collection

      it 'should return the collection for the entity class' do
        collection = instance.collection

        expect(collection).to be_a Bronze::Collections::Collection
        expect(collection.repository).to be repository
        expect(collection.transform).
          to be_a Bronze::Entities::Transforms::EntityTransform
        expect(collection.transform.entity_class).to be entity_class
      end

      describe 'when the default transform is overriden' do
        let(:default_transform) { Bronze::Transforms::IdentityTransform.new }

        before(:example) do
          allow(instance)
            .to receive(:default_transform)
            .and_return(default_transform)
        end

        it 'should return the collection with the default transform' do
          collection = instance.collection

          expect(collection).to be_a Bronze::Collections::Collection
          expect(collection.repository).to be repository
          expect(collection.transform).to be default_transform
        end
      end

      describe 'when the transform is set' do
        let(:transform) { Bronze::Transforms::IdentityTransform.new }

        it 'should return the collection with the given transform' do
          collection = instance.collection

          expect(collection).to be_a Bronze::Collections::Collection
          expect(collection.repository).to be repository
          expect(collection.transform).to be transform
        end
      end
    end

    describe '#repository' do
      include_examples 'should have reader', :repository, ->() { repository }
    end

    describe '#transform' do
      include_examples 'should have reader', :transform

      it 'should return the default transform for the entity class' do
        expect(instance.transform)
          .to be_a Bronze::Entities::Transforms::EntityTransform
        expect(instance.transform.entity_class).to be entity_class
      end

      describe 'when the default transform is overriden' do
        let(:default_transform) { Bronze::Transforms::IdentityTransform.new }

        before(:example) do
          allow(instance)
            .to receive(:default_transform)
            .and_return(default_transform)
        end

        it 'should return the default transform' do
          expect(instance.transform).to be default_transform
        end
      end

      describe 'when the transform is set' do
        let(:transform) { Bronze::Transforms::IdentityTransform.new }

        it 'should return the set transform' do
          expect(instance.transform).to be transform
        end
      end
    end
  end

  shared_examples 'should assign the attributes to the entity' do
    describe '#call' do
      let(:expected_attributes) do
        initial_attributes.dup.tap do |hsh|
          valid_attributes.each do |key, value|
            hsh[key] = value
          end
        end
      end
      let(:entity) { entity_class.new(initial_attributes) }

      it { expect(instance).to respond_to(:call).with(2).arguments }

      describe 'with a valid attributes hash with string keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(valid_attributes)

          instance.call(entity, attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
        end

        it 'should update the attributes', :aggregate_failures do
          call_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end

      describe 'with a valid attributes hash with symbol keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(valid_attributes)

          instance.call(entity, attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == entity
        end

        it 'should update the attributes', :aggregate_failures do
          call_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end
    end
  end

  shared_examples 'should assign, validate, and update the entity' do
    describe '#execute' do
      include_context 'when the repository has many entities'

      let(:entity) do
        collection.matching(:title => 'Astrology Today').limit(1).one
      end # let
      let!(:original_attributes) do
        entity.attributes.tap { |hsh| hsh.delete(:id) }
      end # let
      let(:expected_attributes) do
        original_attributes.dup.tap do |hsh|
          valid_attributes.each do |key, value|
            hsh[key] = value
          end # each
        end # attributes_changed
      end # let

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

        it 'should update the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.find(entity.id)

          expected_attributes.each do |key, value|
            expect(persisted.send key).to be == value
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

        it 'should update the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.find(entity.id)

          expected_attributes.each do |key, value|
            expect(persisted.send key).to be == value
          end # each
        end # it
      end # describe

      describe 'with an entity that is not in the collection' do
        let(:entity) { entity_class.new(initial_attributes) }
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   => Bronze::Collections::Collection::Errors.record_not_found,
            :params => { :id => entity.id }
          } # end expected error
        end # let

        def execute_operation
          instance.execute(entity, valid_attributes)
        end # method execute operation

        include_examples 'should fail and set the errors'

        it 'should set the result' do
          expect(execute_operation.result).to be entity
        end # it

        it 'should update the attributes', :aggregate_failures do
          execute_operation

          expected_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end # each
        end # it
      end # describe

      context 'when the contract validates the entity properties' do
        let(:contract) { entity_contract }

        before(:example) do
          entity_class.const_set(:Contract, contract)
        end # before example

        describe 'with an invalid attributes hash' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            } # end error
          end # let

          def execute_operation
            instance.execute(entity, invalid_attributes)
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be entity
          end # it

          it 'should update the attributes', :aggregate_failures do
            entity = execute_operation.result

            invalid_attributes.each do |key, value|
              next unless entity.respond_to?(key)

              expect(entity.send key).to be == value
            end # each
          end # it

          it 'should not update the persisted attributes', :aggregate_failures \
          do
            execute_operation

            persisted = collection.find(entity.id)

            original_attributes.each do |key, value|
              expect(persisted.send key).to be == value
            end # each
          end # it
        end # describe

        describe 'with a valid attributes hash' do
          def execute_operation
            instance.execute(entity, valid_attributes)
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

          it 'should update the persisted attributes', :aggregate_failures do
            execute_operation

            persisted = collection.find(entity.id)

            expected_attributes.each do |key, value|
              expect(persisted.send key).to be == value
            end # each
          end # it
        end # describe
      end # context

      context 'when the entity class defines uniqueness constraints' do
        before(:example) do
          entity_class.unique :title, :volume
        end # before example

        describe 'with an attributes hash with non-unique attributes' do
          let(:attributes) do
            collection.
              matching(:title => 'The Atlantean Diaspora').
              limit(1).one.
              attributes.tap { |hsh| hsh.delete(:id) }
          end # let

          def execute_operation
            instance.execute(entity, attributes)
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be entity
          end # it

          it 'should update the attributes', :aggregate_failures do
            entity = execute_operation.result

            attributes.each do |key, value|
              next unless entity.respond_to?(key)

              expect(entity.send key).to be == value
            end # each
          end # it

          it 'should not update the persisted attributes', :aggregate_failures \
          do
            execute_operation

            persisted = collection.find(entity.id)

            original_attributes.each do |key, value|
              expect(persisted.send key).to be == value
            end # each
          end # it
        end # describe

        describe 'with an attributes hash with unique attributes' do
          def execute_operation
            instance.execute(entity, valid_attributes)
          end # method execute_operation

          include_examples 'should succeed and clear the errors'

          it 'should set the result to the entity' do
            expect(execute_operation.result).to be entity
          end # it

          it 'should update the attributes', :aggregate_failures do
            entity = execute_operation.result

            expected_attributes.each do |key, value|
              next unless entity.respond_to?(key)

              expect(entity.send key).to be == value
            end # each
          end # it

          it 'should update the persisted attributes', :aggregate_failures \
          do
            execute_operation

            persisted = collection.find(entity.id)

            expected_attributes.each do |key, value|
              expect(persisted.send key).to be == value
            end # each
          end # it
        end # describe
      end # describe
    end # describe
  end # shared_examples

  shared_examples 'should build the entity' do
    describe '#call' do
      describe 'with no arguments' do
        def call_operation
          instance.call
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          instance.call

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end
        end
      end

      describe 'with nil' do
        def call_operation
          instance.call(nil)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end
        end
      end

      describe 'with an empty attributes hash' do
        def call_operation
          instance.call({})
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end
        end
      end

      describe 'with a valid attributes hash with string keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_strings(initial_attributes)

          instance.call(attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end

      describe 'with a valid attributes hash with symbol keys' do
        def call_operation
          tools      = SleepingKingStudios::Tools::Toolbelt.instance
          attributes = tools.hash.convert_keys_to_symbols(initial_attributes)

          instance.call(attributes)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be_a entity_class
        end

        it 'should set the attributes', :aggregate_failures do
          entity = call_operation.value

          initial_attributes.each do |key, value|
            expect(entity.send key).to be == value
          end
        end
      end
    end
  end

  shared_examples 'should build, validate and insert the entity' do
    describe '#execute' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:execute).with(0..1).arguments }

      describe 'with no arguments' do
        def execute_operation
          instance.execute
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be_a entity_class
          expect(instance.result.persisted?).to be true
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end # each
        end # it

        it { expect { execute_operation }.to change(collection, :count).by(1) }

        it 'should set the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.matching(empty_attributes).limit(1).one

          initial_attributes.each_key do |key|
            expect(persisted.send key).to be nil
          end # each
        end # it
      end # describe

      describe 'with nil' do
        def execute_operation
          instance.execute(nil)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be_a entity_class
          expect(instance.result.persisted?).to be true
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end # each
        end # it

        it { expect { execute_operation }.to change(collection, :count).by(1) }

        it 'should set the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.matching(empty_attributes).limit(1).one

          initial_attributes.each_key do |key|
            expect(persisted.send key).to be nil
          end # each
        end # it
      end # describe

      describe 'with an empty attributes hash' do
        def execute_operation
          instance.execute({})
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be_a entity_class
          expect(instance.result.persisted?).to be true
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
          end # each
        end # it

        it { expect { execute_operation }.to change(collection, :count).by(1) }

        it 'should set the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.matching(empty_attributes).limit(1).one

          initial_attributes.each_key do |key|
            expect(persisted.send key).to be nil
          end # each
        end # it
      end # describe

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

        it { expect { execute_operation }.to change(collection, :count).by(1) }

        it 'should set the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.matching(initial_attributes).limit(1).one

          initial_attributes.each do |key, value|
            expect(persisted.send key).to be == value
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

        it { expect { execute_operation }.to change(collection, :count).by(1) }

        it 'should set the persisted attributes', :aggregate_failures do
          execute_operation

          persisted = collection.matching(initial_attributes).limit(1).one

          initial_attributes.each do |key, value|
            expect(persisted.send key).to be == value
          end # each
        end # it
      end # describe

      context 'when the contract validates the entity properties' do
        let(:contract) { entity_contract }

        before(:example) do
          entity_class.const_set(:Contract, contract)
        end # before example

        describe 'with no arguments' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            } # end error
          end # let

          def execute_operation
            instance.execute
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be_a entity_class
          end # it

          it 'should set the attributes', :aggregate_failures do
            entity = execute_operation.result

            initial_attributes.each_key do |key|
              expect(entity.send key).to be nil
            end # each
          end # it

          it { expect { execute_operation }.not_to change(collection, :count) }

          it 'should not persist the entity' do
            expect(collection.matching(empty_attributes).count).to be 0
          end # it
        end # describe

        describe 'with nil' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            } # end error
          end # let

          def execute_operation
            instance.execute(nil)
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be_a entity_class
          end # it

          it 'should set the attributes', :aggregate_failures do
            entity = execute_operation.result

            initial_attributes.each_key do |key|
              expect(entity.send key).to be nil
            end # each
          end # it

          it { expect { execute_operation }.not_to change(collection, :count) }

          it 'should not persist the entity' do
            expect(collection.matching(empty_attributes).count).to be 0
          end # it
        end # describe

        describe 'with an empty attributes hash' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            } # end error
          end # let

          def execute_operation
            instance.execute({})
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be_a entity_class
          end # it

          it 'should set the attributes', :aggregate_failures do
            entity = execute_operation.result

            initial_attributes.each_key do |key|
              expect(entity.send key).to be nil
            end # each
          end # it

          it { expect { execute_operation }.not_to change(collection, :count) }

          it 'should not persist the entity' do
            expect(collection.matching(empty_attributes).count).to be 0
          end # it
        end # describe

        describe 'with an invalid attributes hash' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            } # end error
          end # let

          def execute_operation
            instance.execute(invalid_attributes)
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be_a entity_class
          end # it

          it 'should set the attributes', :aggregate_failures do
            entity = execute_operation.result

            invalid_attributes.each do |key, value|
              next unless entity.respond_to?(key)

              expect(entity.send key).to be == value
            end # each
          end # it

          it { expect { execute_operation }.not_to change(collection, :count) }

          it 'should not persist the entity' do
            expect(collection.matching(empty_attributes).count).to be 0
          end # it
        end # describe

        describe 'with a valid attributes hash' do
          def execute_operation
            instance.execute(initial_attributes)
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

          it 'should persist the entity' do
            expect { execute_operation }.to change(collection, :count).by(1)
          end # it

          it 'should set the persisted attributes', :aggregate_failures do
            execute_operation

            persisted = collection.matching(initial_attributes).limit(1).one

            initial_attributes.each do |key, value|
              expect(persisted.send key).to be == value
            end # each
          end # it
        end # describe
      end # context

      context 'when the entity class defines uniqueness constraints' do
        before(:example) do
          entity_class.unique :title, :volume
        end # before example

        describe 'with an attributes hash with non-unique attributes' do
          let(:attributes) do
            collection.limit(1).one.
              attributes.
              tap { |hsh| hsh.delete(:id) }
          end # let

          def execute_operation
            instance.execute(attributes)
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result' do
            expect(execute_operation.result).to be_a entity_class
          end # it

          it 'should set the attributes', :aggregate_failures do
            entity = execute_operation.result

            attributes.each do |key, value|
              expect(entity.send key).to be == value
            end # each
          end # it

          it { expect { execute_operation }.not_to change(collection, :count) }

          it 'should not persist the entity' do
            expect(collection.matching(empty_attributes).count).to be 0
          end # it
        end # describe

        describe 'with an attributes hash with unique attributes' do
          def execute_operation
            instance.execute(initial_attributes)
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

          it 'should persist the entity' do
            expect { execute_operation }.to change(collection, :count).by(1)
          end # it

          it 'should set the persisted attributes', :aggregate_failures do
            execute_operation

            persisted = collection.matching(initial_attributes).limit(1).one

            initial_attributes.each do |key, value|
              expect(persisted.send key).to be == value
            end # each
          end # it
        end # describe
      end # context
    end # describe
  end # shared_examples

  shared_examples 'should delete the entity from the collection' do
    describe '#call' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:call).with(1).argument }

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

      describe 'with an invalid entity id' do
        let(:entity) { entity_class.new }
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   => Bronze::Collections::Collection::Errors.record_not_found,
            :params => { :id => entity.id }
          }
        end

        def call_operation
          instance.call(entity.id)
        end

        include_examples 'should fail and set the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end

        it { expect { call_operation }.not_to change(collection, :count) }
      end

      describe 'with an invalid entity' do
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

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end

        it { expect { call_operation }.not_to change(collection, :count) }
      end

      describe 'with a valid entity id' do
        let(:entity) { collection.limit(1).one }

        def call_operation
          instance.call(entity.id)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end

        it 'should delete the entity from the collection' do
          expect { call_operation }.to change(collection, :count).by(-1)

          expect(collection.matching(entity.attributes).exists?).to be false
        end
      end

      describe 'with a valid entity' do
        let(:entity) { collection.limit(1).one }

        def call_operation
          instance.call(entity)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be nil
        end

        it 'should delete the entity from the collection' do
          expect { call_operation }.to change(collection, :count).by(-1)

          expect(collection.matching(entity.attributes).exists?).to be false
        end
      end
    end
  end

  shared_examples 'should find the entities with given primary keys' do
    describe '#call' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:call).with(0..1).arguments }

      describe 'with no arguments' do
        def call_operation
          instance.call
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with nil' do
        def call_operation
          instance.call(nil)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 1
          expect(instance.errors).to include(
            :type   => error_context.record_not_found,
            :path   => [plural_entity_name.intern],
            :params => { :id => nil }
          )
        }

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
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
            :path   => [plural_entity_name.intern],
            :params => { :id => entity_id }
          )
        }

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with a valid entity id' do
        let(:entity)    { collection.limit(1).one }
        let(:entity_id) { entity.id }

        def call_operation
          instance.call(entity_id)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly entity
        end
      end

      describe 'with an empty array' do
        def call_operation
          instance.call([])
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with an array of invalid entity ids' do
        let(:entity_ids) { Array.new(3) { entity_class.new.id } }

        def call_operation
          instance.call(entity_ids)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 3

          entity_ids.each do |entity_id|
            expect(instance.errors).to include(
              :type   => error_context.record_not_found,
              :path   => [plural_entity_name.intern],
              :params => { :id => entity_id }
            )
          end
        }

        it 'should set the result' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to be == []
        end
      end

      describe 'with an array of mixed valid and invalid entity ids' do
        let(:invalid_entity_ids) { Array.new(3) { entity_class.new.id } }
        let(:entities)           { collection.limit(3).to_a }
        let(:valid_entity_ids)   { entities.map(&:id) }
        let(:entity_ids)         { [*invalid_entity_ids, *valid_entity_ids] }

        def call_operation
          instance.call(entity_ids)
        end

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 3

          invalid_entity_ids.each do |entity_id|
            expect(instance.errors).to include(
              :type   => error_context.record_not_found,
              :path   => [plural_entity_name.intern],
              :params => { :id => entity_id }
            )
          end
        }

        it 'should set the result to the found entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*entities)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end

      describe 'with an array of valid entity ids' do
        let(:entities)   { collection.limit(3).to_a }
        let(:entity_ids) { entities.map(&:id) }

        def call_operation
          instance.call(entity_ids)
        end

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the found entities' do
          call_operation

          expect(instance.result).to be_a Cuprum::Result
          expect(instance.result.value).to contain_exactly(*entities)

          instance.result.value.each do |entity|
            expect(entity.persisted?).to be true
          end
        end
      end
    end
  end

  shared_examples 'should find the entities matching the selector' do
    describe '#call' do
      let(:selector) { {} }
      let(:expected) { collection.matching(selector).to_a }

      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:call).with(1).argument }

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
  end

  shared_examples 'should find the entity with the given primary key' do
    describe '#call' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:call).with(1).argument }

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
  end

  shared_examples 'should insert the entity into the collection' do
    describe '#call' do
      it { expect(instance).to respond_to(:call).with(1).argument }

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
  end

  shared_examples 'should update the entity in the collection' do
    describe '#call' do
      include_context 'when the repository has many entities'

      let(:expected_attributes) do
        entity.attributes.tap do |hsh|
          valid_attributes.each do |key, value|
            hsh[key] = value
          end
        end
      end

      it { expect(instance).to respond_to(:call).with(1).argument }

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
  end

  shared_examples 'should validate the entity with the contract' do
    describe '#call' do
      it { expect(instance).to respond_to(:call).with(1).argument }

      context 'when the contract has no constraints' do
        let(:contract) { Bronze::Contracts::Contract.new }

        describe 'with nil' do
          def call_operation
            instance.call(nil)
          end

          include_examples 'should succeed and clear the errors'

          it 'should set the result to nil' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be nil
          end
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
            expect(instance.result.value).to be == entity
          end
        end
      end

      context 'when the contract validates the entity properties' do
        let(:contract) { entity_contract }

        describe 'with nil' do
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
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

        describe 'with an invalid entity' do
          let(:entity) { entity_class.new(initial_attributes) }
          let(:expected_error) do
            {
              :type   => Bronze::Constraints::PresenceConstraint::EMPTY_ERROR,
              :path   => [entity_name.intern, :title],
              :params => {}
            }
          end

          before(:example) do
            entity.assign(invalid_attributes)
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

        describe 'with a valid entity' do
          let(:entity) { entity_class.new(initial_attributes) }

          def call_operation
            instance.call(entity)
          end

          include_examples 'should succeed and clear the errors'

          it 'should set the result to the entity' do
            call_operation

            expect(instance.result).to be_a Cuprum::Result
            expect(instance.result.value).to be == entity
          end
        end
      end
    end
  end

  shared_examples 'should validate the uniqueness of the entity' do
    describe '#execute' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:execute).with(1).argument }

      describe 'with nil' do
        def execute_operation
          instance.execute(nil)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to nil' do
          expect(execute_operation.result).to be nil
        end # it
      end # describe

      describe 'with an entity that does not implement uniqueness' do
        options = { :base_class => Bronze::Entities::BaseEntity }
        example_class 'Spec::SimplePeriodical', options do |klass|
          klass.send :include, Bronze::Entities::Attributes
          klass.send :include, Bronze::Entities::PrimaryKey

          klass.attribute :title,  String
          klass.attribute :volume, Integer
        end # example_class

        let(:entity_class) { Spec::SimplePeriodical }
        let(:entity)       { entity_class.new(initial_attributes) }

        def execute_operation
          instance.execute(entity)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the entity' do
          expect(execute_operation.result).to be entity
        end # it
      end # describe

      describe 'with an entity' do
        let(:entity) { entity_class.new(initial_attributes) }

        def execute_operation
          instance.execute(entity)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the entity' do
          expect(execute_operation.result).to be entity
        end # it
      end # describe

      context 'when the entity class defines uniqueness constraints' do
        before(:example) do
          entity_class.unique :title, :volume
        end # before example

        describe 'with an entity with unique attributes' do
          let(:entity) { entity_class.new(initial_attributes) }

          def execute_operation
            instance.execute(entity)
          end # method execute_operation

          include_examples 'should succeed and clear the errors'

          it 'should set the result to the entity' do
            expect(execute_operation.result).to be entity
          end # it
        end # describe

        describe 'with an entity with non-unique attributes' do
          let(:attributes) do
            collection.limit(1).one.
              attributes.
              tap { |hsh| hsh.delete(:id) }
          end # let
          let(:entity) { entity_class.new(attributes) }
          let(:expected_error) do
            error_types = Bronze::Entities::Constraints::UniquenessConstraint

            {
              :type => error_types::NOT_UNIQUE_ERROR,
              :path => [:periodical]
            } # end error
          end # let

          def execute_operation
            instance.execute(entity)
          end # method execute_operation

          include_examples 'should fail and set the errors'

          it 'should set the result to the entity' do
            expect(execute_operation.result).to be entity
          end # it
        end # describe
      end # context
    end # describe
  end # shared_examples
end # module
