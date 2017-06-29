# spec/bronze/entities/operations/entity_operation_examples.rb

require 'bronze/entities/entity'

require 'patina/collections/simple/repository'

module Spec::Entities
  module Operations; end
end # module

module Spec::Entities::Operations::EntityOperationExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_context 'when the entity class is defined' do
    options = { :base_class => Bronze::Entities::Entity }
    example_class 'Spec::Periodical', options do |klass|
      klass.attribute :title,  String
      klass.attribute :volume, Integer
    end # example_class

    let(:entity_class)       { Spec::Periodical }
    let(:entity_name)        { 'periodical' }
    let(:plural_entity_name) { 'periodicals' }

    let(:initial_attributes) do
      {
        :title  => 'Crystal Healing Digest',
        :volume => 7
      } # end hash
    end # let
    let(:valid_attributes)   { { :title => 'Cryptozoology Monthly' } }
    let(:invalid_attributes) { { :title => nil, :publisher => 'Bigfoot' } }
  end # shared_context

  shared_context 'when the repository is defined' do
    let(:repository) { Patina::Collections::Simple::Repository.new }
    let(:collection) { repository.collection(entity_class) }
  end # shared_context

  shared_context 'when the repository has many entities' do
    before(:example) do
      [
        'Astrology Today',
        'Journal of Applied Phrenology',
        'The Atlantean Diaspora'
      ]. # end array
        each do |title|
          1.upto(3) do |volume|
            attributes =
              initial_attributes.merge(:title => title, :volume => volume)
            entity     = entity_class.new(attributes)

            collection.insert(entity)
          end # upto
        end # each
    end # before example
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

  shared_examples 'should fail and set the errors' do |proc = nil|
    it 'should fail and set the errors' do
      execute_operation

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
      end # if

      instance_exec(&proc) unless proc.nil?
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
        expect(subclass.new(*arguments).entity_class).to be entity_class
      end # it
    end # describe

    describe '#entity_class' do
      include_examples 'should have reader',
        :entity_class,
        ->() { entity_class }
    end # describe
  end # shared_examples

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
      end # it
    end # describe

    describe '#repository' do
      include_examples 'should have reader', :repository, ->() { repository }
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
      it { expect(instance).to respond_to(:execute).with(0..1).arguments }

      describe 'with no arguments' do
        def execute_operation
          instance.execute
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result' do
          execute_operation

          expect(instance.result).to be_a entity_class
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
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
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
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
        end # it

        it 'should set the attributes', :aggregate_failures do
          entity = execute_operation.result

          initial_attributes.each_key do |key|
            expect(entity.send key).to be nil
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

  shared_examples 'should delete the entity from the collection' do
    describe '#execute' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:execute).with(1).argument }

      describe 'with nil' do
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   =>
              Bronze::Collections::Collection::Errors.primary_key_missing,
            :params => { :key => :id }
          } # end expected error
        end # let

        def execute_operation
          instance.execute(nil)
        end # method execute operation

        include_examples 'should fail and set the errors'

        it { expect { execute_operation }.not_to change(collection, :count) }
      end # describe

      describe 'with an invalid entity id' do
        let(:entity) { entity_class.new }
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   => Bronze::Collections::Collection::Errors.record_not_found,
            :params => { :id => entity.id }
          } # end expected error
        end # let

        def execute_operation
          instance.execute(entity.id)
        end # method execute operation

        include_examples 'should fail and set the errors'

        it { expect { execute_operation }.not_to change(collection, :count) }
      end # describe

      describe 'with an invalid entity' do
        let(:entity) { entity_class.new }
        let(:expected_error) do
          {
            :path   => [entity_name.intern],
            :type   => Bronze::Collections::Collection::Errors.record_not_found,
            :params => { :id => entity.id }
          } # end expected error
        end # let

        def execute_operation
          instance.execute(entity)
        end # method execute operation

        include_examples 'should fail and set the errors'

        it { expect { execute_operation }.not_to change(collection, :count) }
      end # describe

      describe 'with a valid entity id' do
        let(:entity) { collection.limit(1).one }

        def execute_operation
          instance.execute(entity.id)
        end # method execute operation

        include_examples 'should succeed and clear the errors'

        it 'should delete the entity from the collection' do
          expect { execute_operation }.to change(collection, :count).by(-1)

          expect(collection.matching(entity.attributes).exists?).to be false
        end # it
      end # describe

      describe 'with a valid entity' do
        let(:entity) { collection.limit(1).one }

        def execute_operation
          instance.execute(entity)
        end # method execute operation

        include_examples 'should succeed and clear the errors'

        it 'should delete the entity from the collection' do
          expect { execute_operation }.to change(collection, :count).by(-1)

          expect(collection.matching(entity.attributes).exists?).to be false
        end # it
      end # describe
    end # describe
  end # shared_examples

  shared_examples 'should find the entities with given primary keys' do
    describe '#execute' do
      include_context 'when the repository has many entities'

      it { expect(instance).to respond_to(:execute).with(1).argument }

      describe 'with no arguments' do
        def execute_operation
          instance.execute
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to an empty array' do
          expect(execute_operation.result).to be == []
        end # it
      end # describe

      describe 'with nil' do
        def execute_operation
          instance.execute(nil)
        end # method execute_operation

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 1
          expect(instance.errors).to include(
            :type   => error_context.record_not_found,
            :path   => [plural_entity_name.intern],
            :params => { :id => nil }
          ) # end include
        } # end lambda

        it 'should set the result to an empty array' do
          expect(execute_operation.result).to be == []
        end # it
      end # describe

      describe 'with an invalid entity id' do
        let(:entity_id) { entity_class.new.id }

        def execute_operation
          instance.execute(entity_id)
        end # method execute_operation

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 1
          expect(instance.errors).to include(
            :type   => error_context.record_not_found,
            :path   => [plural_entity_name.intern],
            :params => { :id => entity_id }
          ) # end include
        } # end lambda

        it 'should set the result to an empty array' do
          expect(execute_operation.result).to be == []
        end # it
      end # describe

      describe 'with a valid entity id' do
        let(:entity)    { collection.limit(1).one }
        let(:entity_id) { entity.id }

        def execute_operation
          instance.execute(entity_id)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the found entities' do
          expect(execute_operation.result).to be == [entity]
        end # it
      end # describe

      describe 'with an empty array' do
        def execute_operation
          instance.execute([])
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to an empty array' do
          expect(execute_operation.result).to be == []
        end # it
      end # describe

      describe 'with an array of invalid entity ids' do
        let(:entity_ids) do
          Array.new(3) { entity_class.new.id }
        end # let

        def execute_operation
          instance.execute(entity_ids)
        end # method execute_operation

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 3

          entity_ids.each do |entity_id|
            expect(instance.errors).to include(
              :type   => error_context.record_not_found,
              :path   => [plural_entity_name.intern],
              :params => { :id => entity_id }
            ) # end include
          end # each
        } # end lambda

        it 'should set the result to an empty array' do
          expect(execute_operation.result).to be == []
        end # it
      end # describe

      describe 'with an array of mixed valid and invalid entity ids' do
        let(:invalid_entity_ids) do
          Array.new(3) { entity_class.new.id }
        end # let
        let(:entities)         { collection.limit(3).to_a }
        let(:valid_entity_ids) { entities.map(&:id) }
        let(:entity_ids)       { [*invalid_entity_ids, *valid_entity_ids] }

        def execute_operation
          instance.execute(entity_ids)
        end # method execute_operation

        include_examples 'should fail and set the errors', lambda {
          error_context = Bronze::Collections::Collection::Errors

          expect(instance.errors.size).to be 3

          invalid_entity_ids.each do |entity_id|
            expect(instance.errors).to include(
              :type   => error_context.record_not_found,
              :path   => [plural_entity_name.intern],
              :params => { :id => entity_id }
            ) # end include
          end # each
        } # end lambda

        it 'should set the result to the found entities' do
          expect(execute_operation.result).to contain_exactly(*entities)
        end # it
      end # describe

      describe 'with an array of valid entity ids' do
        let(:entities)   { collection.limit(3).to_a }
        let(:entity_ids) { entities.map(&:id) }

        def execute_operation
          instance.execute(entity_ids)
        end # method execute_operation

        include_examples 'should succeed and clear the errors'

        it 'should set the result to the found entities' do
          expect(execute_operation.result).to contain_exactly(*entities)
        end # it
      end # describe
    end # describe
  end # shared_examples
end # module
