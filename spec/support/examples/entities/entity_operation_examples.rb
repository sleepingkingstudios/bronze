require 'bronze/contracts/contract'
require 'bronze/entities/entity'
require 'bronze/transforms/identity_transform'

require 'patina/collections/simple/repository'

require 'support/examples/entities'

module Spec::Support::Examples::Entities
  module EntityOperationExamples
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
  end
end
