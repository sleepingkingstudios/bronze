# spec/patina/operations/resources/resource_operation_examples.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/collections/collection'
require 'bronze/constraints/constraint_examples'
require 'bronze/constraints/failure_constraint'
require 'bronze/constraints/success_constraint'
require 'bronze/contracts/type_contract_examples'
require 'bronze/entities/entity'
require 'bronze/entities/transforms/entity_transform'
require 'bronze/errors/error'
require 'bronze/transforms/identity_transform'

module Spec::Operations
  module ResourceOperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    include Spec::Contracts::TypeContractExamples

    shared_context 'when a resource class is defined' do
      let(:resource_class) { Spec::ArchivedPeriodical }

      options = { :base_class => Bronze::Entities::Entity }
      mock_class Spec, :ArchivedPeriodical, options do |klass|
        klass.attribute :title,  String
        klass.attribute :volume, Integer
      end # mock_class
    end # shared_context

    shared_context 'when the collection contains one resource' do
      let(:resource_attributes) do
        { :title => 'Your Weekly Horoscope', :volume => 0 }
      end # let
      let(:resource) { resource_class.new resource_attributes }

      before(:example) { instance.resource_collection.insert resource }
    end # shared_context

    shared_context 'when the collection contains many resources' do
      let(:resources_attributes) do
        ary = []

        title = 'Astrology Today'
        1.upto(3) { |i| ary << { :title => title, :volume => i } }

        title = 'Journal of Applied Phrenology'
        4.upto(6) { |i| ary << { :title => title, :volume => i } }

        ary
      end # let
      let(:resources) do
        resources_attributes.map { |hsh| resource_class.new hsh }
      end # let

      before(:example) do
        resources.each do |resource|
          instance.resource_collection.insert resource
        end # each
      end # before
    end # shared_context

    shared_examples 'should require a resource' do
      describe 'should require a resource' do
        let(:resource_id) { '0' }
        let(:errors) do
          error_definitions = Bronze::Collections::Collection::Errors

          Bronze::Errors::Errors.new.tap do |errors|
            errors[:resource].add(
              error_definitions::RECORD_NOT_FOUND,
              :id => resource_id
            ) # end add error
          end # tap
        end # let

        it { expect(call_operation).to be false }

        it 'should set the resource' do
          call_operation

          expect(instance.resource).to be nil
        end # it

        it 'should set the failure message' do
          call_operation

          expect(instance.failure_message).
            to be == described_class::RESOURCE_NOT_FOUND
        end # it

        it 'should set the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          call_operation

          expect(instance.errors).to be == errors
        end # it
      end # describe
    end # shared_context

    shared_examples 'should implement the ResourceOperation methods' do
      include_examples 'should implement the TypeContract methods'

      describe '::[]' do
        let(:resource_class) do
          Class.new do
            def self.name
              'Namespace::ResourceClass'
            end # class method name
          end # class
        end # let

        it { expect(described_class).to respond_to(:[]).with(1).argument }

        it 'should create a subclass' do
          subclass = described_class[resource_class]

          expect(subclass).to be_a Class
          expect(subclass).to be < described_class

          expect(subclass.name).
            to be == "#{described_class.name}[#{resource_class.name}]"
        end # it

        it 'should set the resource class' do
          subclass = described_class[resource_class]

          expect(subclass.resource_class).to be resource_class
        end # it
      end # describe

      describe '::resource_class' do
        it 'should define the reader' do
          expect(described_class).
            to have_reader(:resource_class).
            with_value(resource_class)
        end # it
      end # describe

      describe '::resource_class=' do
        let(:new_resource_class) { Class.new }

        it 'should define the writer' do
          expect(described_class).not_to respond_to(:resource_class=)

          expect(described_class).
            to respond_to(:resource_class=, true).
            with(1).argument
        end # it

        it 'should set the resource class' do
          expect { described_class.send :resource_class=, new_resource_class }.
            to change(described_class, :resource_class).
            to be new_resource_class
        end # it
      end # describe

      describe '::resource_contract' do
        it 'should alias the method' do
          original_method = described_class.method(:contract)
          aliased_method  = described_class.method(:resource_contract)

          expect(original_method.source_location).
            to be == aliased_method.source_location

          expect(aliased_method.original_name).to be == :contract
        end # it
      end # describe

      describe '::resource_contract?' do
        it { expect(described_class).to have_predicate(:resource_contract?) }

        it { expect(described_class.resource_contract?).to be false }

        context 'when a resource contract has been defined' do
          before(:example) do
            described_class.contract do
              constrain :attribute_types => true
            end # contract
          end # before

          it { expect(described_class.resource_contract?).to be true }
        end # context

        context 'when a resource contract has been set' do
          let(:contract) { Bronze::Contracts::Contract.new }

          before(:example) do
            described_class.contract(contract)
          end # before

          it { expect(described_class.resource_contract?).to be true }
        end # context
      end # describe

      describe '#repository' do
        include_examples 'should have reader',
          :repository,
          ->() { be == repository }
      end # describe

      describe '#repository=' do
        let(:new_repository) { double('repository') }

        it 'should define the private writer' do
          expect(instance).not_to respond_to(:repository=)

          expect(instance).to respond_to(:repository=, true).with(1).argument
        end # it

        it 'should set the repository' do
          expect { instance.send :repository=, new_repository }.
            to change(instance, :repository).
            to be new_repository
        end # it
      end # describe

      describe '#resource_class' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:resource_class).
            with_value(resource_class)
        end # it
      end # describe

      describe '#resource_collection' do
        let(:collection_name) { 'archived_periodicals' }

        it 'should define the method' do
          expect(instance).to respond_to(:resource_collection).with(0).arguments
        end # it

        it 'should return a collection' do
          collection = instance.resource_collection

          expect(collection).to be_a Bronze::Collections::Reference::Collection
          expect(collection.name).to be == collection_name
          expect(collection.repository).to be repository

          transform = collection.transform

          expect(transform).
            to be_a Bronze::Entities::Transforms::EntityTransform
          expect(transform.entity_class).to be resource_class
        end # it

        context 'when a custom transform is defined' do
          let(:transform) { Bronze::Transforms::IdentityTransform.new }

          before(:example) do
            allow(instance).
              to receive(:resource_transform_for).
              and_return(transform)
          end # before example

          it 'should return a collection' do
            collection = instance.resource_collection

            expect(collection).
              to be_a Bronze::Collections::Reference::Collection
            expect(collection.name).to be == collection_name
            expect(collection.repository).to be repository

            transform = collection.transform

            expect(transform).to be transform
          end # it
        end # context
      end # describe

      describe '#resource_contract' do
        let(:contract) { double('contract') }

        include_examples 'should have reader', :resource_contract, nil

        context 'when a resource contract has been defined' do
          before(:example) do
            described_class.contract do
              constrain :attribute_types => true
            end # contract
          end # before

          it 'should delegate to the class' do
            expect(instance.resource_contract).to be described_class.contract
          end # it
        end # context

        context 'when a resource contract has been set' do
          let(:contract) { Bronze::Contracts::Contract.new }

          before(:example) do
            described_class.contract(contract)
          end # before

          it 'should delegate to the class' do
            expect(instance.resource_contract).to be contract
          end # it
        end # context

        context 'when a resource class is defined' do
          let(:resource_class) { Spec::ArchivedPeriodical }

          context 'when the resource class has a ::Contract constant' do
            let(:contract_class) { Class.new(Bronze::Contracts::Contract) }

            before(:example) do
              resource_class.const_set :Contract, contract_class
            end # before example

            it 'should return the resource class contract' do
              expect(instance.resource_contract).to be_a contract_class
            end # it
          end # context

          context 'when the resource class has a ::contract method' do
            let(:contract) { Bronze::Contracts::Contract.new }

            before(:example) do
              resource_class.send :include, Bronze::Contracts::TypeContract
            end # before example

            it 'should return the resource class contract' do
              expect(instance.resource_contract).to be resource_class.contract
            end # it
          end # context
        end # wrap_context
      end # describe

      describe '#resource_name' do
        let(:expected) { 'archived_periodicals' }

        include_examples 'should have reader',
          :resource_name,
          ->() { be == expected }
      end # describe

      describe '#resource_valid?' do
        desc = 'should return false and the errors object'
        shared_examples desc do |proc = nil|
          describe 'should return false and the errors object' do
            let(:match_method) { defined?(super()) ? super() : :match }

            it do
              result, errors = instance.send match_method, object

              expect(result).to be false

              if proc.is_a?(Proc)
                instance_exec(errors, &proc)
              elsif defined?(error_type)
                expect(errors).to include { |error|
                  next false unless error.type == error_type

                  if defined?(error_params)
                    next false unless error.params == error_params
                  end # if

                  true
                } # end errors
              else
                expect(errors).not_to satisfy(&:empty?)
              end # if
            end # it
          end # describe
        end # shared_examples

        shared_examples 'should return true and an empty errors object' do
          describe 'should return false and the errors object' do
            let(:match_method) { defined?(super()) ? super() : :match }

            it do
              result, errors = instance.send match_method, object

              expect(result).to be true
              expect(errors).to satisfy(&:empty?)
            end # it
          end # describe
        end # shared_examples

        let(:match_method) { :resource_valid? }
        let(:object)       { Object.new }

        it 'should define the method' do
          expect(instance).to respond_to(:resource_valid?).with(1).argument
        end # it

        include_examples 'should return true and an empty errors object'

        context 'when there is a contract that matches the object' do
          before(:example) do
            constraint = Spec::Constraints::SuccessConstraint.new

            allow(instance).
              to receive(:resource_contract).
              and_return(constraint)
          end # before example

          include_examples 'should return true and an empty errors object'
        end # context

        context 'when there is a contract that does not match the object' do
          let(:error_type) do
            Spec::Constraints::FailureConstraint::INVALID_ERROR
          end # let

          before(:example) do
            constraint = Spec::Constraints::FailureConstraint.new

            allow(instance).
              to receive(:resource_contract).
              and_return(constraint)
          end # before example

          include_examples 'should return false and the errors object'
        end # context
      end # describe
    end # shared_examples

    shared_examples 'should implement the ManyResourcesOperation methods' do
      include_examples 'should implement the ResourceOperation methods'

      describe '#expected_count' do
        include_examples 'should have reader', :expected_count, nil
      end # describe

      describe '#find_resources' do
        shared_examples 'should set and return the resources' do
          let(:ids_count)   { arguments.flatten.count }
          let(:missing_ids) { arguments.flatten - resources.map(&:id) }

          it 'should return the resources' do
            resources = instance.send(:find_resources, *arguments)

            expect(resources).to be == expected
          end # it

          it 'should set the resources' do
            resources = nil

            expect { resources = instance.send(:find_resources, *arguments) }.
              to change(instance, :resources)

            expect(instance.resources).to be == expected
            expect(instance.resources_count).to be == expected.count
            expect(instance.expected_count).to be == ids_count
            expect(instance.missing_resource_ids).to be == missing_ids
          end # it
        end # shared_examples

        let(:arguments) { [] }
        let(:expected)  { [] }
        let(:resources) { [] }

        it 'should define the method' do
          expect(instance).
            to respond_to(:find_resources, true).
            with_unlimited_arguments
        end # it

        include_examples 'should set and return the resources'

        wrap_context 'when the collection contains many resources' do
          include_examples 'should set and return the resources'

          describe 'with a non-matching list of ids' do
            let(:arguments) { Array.new(3) { Bronze::Entities::Ulid.generate } }

            include_examples 'should set and return the resources'

            describe 'with an array of ids' do
              let(:arguments) { [super()] }

              include_examples 'should set and return the resources'
            end # describe
          end # describe

          describe 'with a partially matching list of ids' do
            let(:arguments) do
              resources[0...3].map(&:id).concat(
                Array.new(3) { Bronze::Entities::Ulid.generate }
              ) # end concat
            end # let
            let(:expected) { resources[0...3] }

            include_examples 'should set and return the resources'

            describe 'with an array of ids' do
              let(:arguments) { [super()] }

              include_examples 'should set and return the resources'
            end # describe
          end # describe

          describe 'with a matching list of ids' do
            let(:arguments) do
              resources[0...3].map(&:id)
            end # let
            let(:expected) { resources[0...3] }

            include_examples 'should set and return the resources'

            describe 'with an array of ids' do
              let(:arguments) { [super()] }

              include_examples 'should set and return the resources'
            end # describe
          end # describe
        end # wrap_context
      end # describe

      describe '#missing_resource_ids' do
        include_examples 'should have reader', :missing_resource_ids, nil
      end # describe

      describe '#require_resources' do
        shared_examples 'should set the resources' do
          it 'should set the resources' do
            expect { instance.send(:require_resources, *arguments) }.
              to change(instance, :resources)

            expect(instance.resources).to be == expected
          end # it
        end # shared_examples

        shared_examples 'should return false and set the errors' do
          let(:missing_ids) { arguments.flatten - resources.map(&:id) }

          before(:example) do
            instance.instance_variable_set :@errors, Bronze::Errors::Errors.new
          end # before example

          include_examples 'should set the resources'

          it 'should return false' do
            expect(instance.send :require_resources, *arguments).to be false
          end # it

          it 'should append the errors' do
            error_definitions = Bronze::Collections::Collection::Errors

            instance.send :require_resources, *arguments

            missing_ids.each do |missing_id|
              expected =
                Bronze::Errors::Error.new [:resources, missing_id.to_s.intern],
                  error_definitions::RECORD_NOT_FOUND,
                  :id => missing_id

              expect(instance.errors).to include expected
            end # each
          end # it

          it 'should set the failure message' do
            instance.send :require_resources, *arguments

            expect(instance.failure_message).
              to be == described_class::RESOURCES_NOT_FOUND
          end # it
        end # shared_examples

        shared_examples 'should return true and set the resources' do
          include_examples 'should set the resources'

          it 'should return true' do
            expect(instance.send :require_resources, *arguments).to be true
          end # it

          it 'should not append an error' do
            expect { instance.send :require_resources, *arguments }.
              not_to change(instance, :errors)
          end # it

          it 'should not set a failure message' do
            instance.send :require_resources, *arguments

            expect(instance.failure_message).to be nil
          end # it
        end # shared_examples

        let(:arguments) { [] }
        let(:expected)  { [] }
        let(:resources) { [] }

        it 'should define the method' do
          expect(instance).
            to respond_to(:find_resources, true).
            with_unlimited_arguments
        end # it

        include_examples 'should return true and set the resources'

        wrap_context 'when the collection contains many resources' do
          include_examples 'should return true and set the resources'

          describe 'with a non-matching list of ids' do
            let(:arguments) { Array.new(3) { Bronze::Entities::Ulid.generate } }

            include_examples 'should return false and set the errors'

            describe 'with an array of ids' do
              let(:arguments) { [super()] }

              include_examples 'should return false and set the errors'
            end # describe
          end # describe

          describe 'with a partially matching list of ids' do
            let(:arguments) do
              resources[0...3].map(&:id).concat(
                Array.new(3) { Bronze::Entities::Ulid.generate }
              ) # end concat
            end # let
            let(:expected) { resources[0...3] }

            include_examples 'should return false and set the errors'

            describe 'with an array of ids' do
              let(:arguments) { [super()] }

              include_examples 'should return false and set the errors'
            end # describe
          end # describe

          describe 'with a matching list of ids' do
            let(:arguments) do
              resources[0...3].map(&:id)
            end # let
            let(:expected) { resources[0...3] }

            include_examples 'should return true and set the resources'

            describe 'with an array of ids' do
              let(:arguments) { [super()] }

              include_examples 'should return true and set the resources'
            end # describe
          end # describe
        end # describe
      end # describe

      describe '#resources' do
        include_examples 'should have reader', :resources, nil
      end # describe

      describe '#resources_count' do
        include_examples 'should have reader', :resources_count, nil
      end # describe
    end # shared_examples

    shared_examples 'should implement the MatchingResourcesOperation methods' do
      include_examples 'should implement the ResourceOperation methods'

      describe '#find_resources' do
        shared_examples 'should set and return the resources' do
          it 'should return the resources' do
            resources = instance.send(:find_resources, *arguments)

            expect(resources).to be == expected
          end # it

          it 'should set the resources' do
            resources = nil

            expect { resources = instance.send(:find_resources, *arguments) }.
              to change(instance, :resources)

            expect(instance.resources).to be == expected
            expect(instance.resources_count).to be == expected.count
          end # it
        end # shared_examples

        let(:arguments) { [] }
        let(:expected)  { [] }

        it 'should define the method' do
          expect(instance).
            to respond_to(:find_resources, true).
            with(0).arguments.
            and_keywords(:matching)
        end # it

        include_examples 'should set and return the resources'

        wrap_context 'when the collection contains many resources' do
          let(:expected) { resources }

          include_examples 'should set and return the resources'
        end # wrap_context

        describe 'with :matching => selector' do
          let(:selector)  { { :title => 'Journal of Applied Phrenology' } }
          let(:arguments) { super() << { :matching => selector } }

          include_examples 'should set and return the resources'

          wrap_context 'when the collection contains many resources' do
            let(:expected) do
              resources.select do |resource|
                resource.title == selector[:title]
              end # select
            end # let

            include_examples 'should set and return the resources'
          end # wrap_context
        end # describe
      end # describe

      describe '#resources' do
        include_examples 'should have reader', :resources, nil
      end # describe

      describe '#resources_count' do
        include_examples 'should have reader', :resources_count, nil
      end # describe
    end # shared_examples

    shared_examples 'should implement the OneResourceOperation methods' do
      include_examples 'should implement the ResourceOperation methods'

      describe '#build_resource' do
        let(:attributes) { {} }

        it 'should define the method' do
          expect(instance).to respond_to(:build_resource, true).with(1).argument
        end # it

        it 'should build an instance of the resource class' do
          resource = instance.send :build_resource, attributes
          expected = {}

          resource_class.attributes.each do |attr_name, _|
            expected[attr_name] = attributes[attr_name]
          end # each

          expected = expected.merge(:id => resource.id)

          expect(resource).to be_a resource_class
          expect(resource.attributes).to be == expected
        end # it

        it 'should set the resource' do
          resource = nil

          expect { resource = instance.send :build_resource, attributes }.
            to change(instance, :resource)

          expect(instance.resource).to be == resource
        end # it

        describe 'with a hash with String keys' do
          let(:attributes) do
            { 'title' => 'Parapsychology Weekly', 'volume' => 0 }
          end # let

          it 'should build an instance of the resource class' do
            tools    = SleepingKingStudios::Tools::Toolbelt.instance
            resource = instance.send :build_resource, attributes
            expected = tools.hash.convert_keys_to_symbols(attributes)

            resource_class.attributes.each do |attr_name, _|
              expected[attr_name] ||= attributes[attr_name]
            end # each

            expected = expected.merge(:id => resource.id)

            expect(resource).to be_a resource_class
            expect(resource.attributes).to be == expected
          end # it
        end # describe

        describe 'with a hash with Symbol keys' do
          let(:attributes) do
            { :title => 'Parapsychology Weekly', :volume => 0 }
          end # let

          it 'should build an instance of the resource class' do
            resource = instance.send :build_resource, attributes
            expected = attributes

            resource_class.attributes.each do |attr_name, _|
              expected[attr_name] ||= attributes[attr_name]
            end # each

            expected = expected.merge(:id => resource.id)

            expect(resource).to be_a resource_class
            expect(resource.attributes).to be == expected
          end # it
        end # describe
      end # describe

      describe '#find_resource' do
        let(:resource_id) { '0' }
        let(:attributes)  { { :id => resource_id } }
        let(:resource)    { resource_class.new(attributes) }

        it 'should define the method' do
          expect(instance).to respond_to(:find_resource, true).with(1).argument
        end # it

        context 'when the repository does not have the requested resource' do
          it 'should return nil' do
            expect(instance.send :find_resource, resource_id).to be nil
          end # it

          it 'should clear the resource' do
            instance.send :find_resource, resource_id

            expect(instance.resource).to be nil
          end # it
        end # context

        context 'when the repository has the requested resource' do
          before(:example) { instance.resource_collection.insert(resource) }

          it 'should return the resource' do
            expect(instance.send :find_resource, resource_id).to be == resource
          end # it

          it 'should set the resource' do
            expect { instance.send :find_resource, resource_id }.
              to change(instance, :resource)

            expect(instance.resource).to be == resource
          end # it
        end # context
      end # describe

      describe '#require_resource' do
        let(:expected) do
          error_definitions = Bronze::Collections::Collection::Errors

          Bronze::Errors::Error.new [:resource],
            error_definitions::RECORD_NOT_FOUND,
            :id => resource_id
        end # let
        let(:resource_id) { '0' }
        let(:attributes)  { { :id => resource_id } }
        let(:resource)    { resource_class.new(attributes) }

        before(:example) do
          instance.instance_variable_set :@errors, Bronze::Errors::Errors.new
        end # before example

        it 'should define the method' do
          expect(instance).
            to respond_to(:require_resource, true).
            with(1).argument
        end # it

        context 'when the repository does not have the requested resource' do
          it 'should return false' do
            expect(instance.send :require_resource, resource_id).to be false
          end # it

          it 'should clear the resource' do
            instance.send :require_resource, resource_id

            expect(instance.resource).to be nil
          end # it

          it 'should append the error' do
            instance.send :require_resource, resource_id

            expect(instance.errors).to include(expected)
          end # it
        end # context

        context 'when the repository has the requested resource' do
          before(:example) { instance.resource_collection.insert(resource) }

          it 'should return true' do
            expect(instance.send :require_resource, resource_id).to be true
          end # it

          it 'should set the resource' do
            expect { instance.send :require_resource, resource_id }.
              to change(instance, :resource)

            expect(instance.resource).to be == resource
          end # it

          it 'should not append an error' do
            expect { instance.send :require_resource, resource_id }.
              not_to change(instance, :errors)
          end # it
        end # context
      end # describe

      describe '#validate_resource' do
        let(:resource) { Object.new }

        it 'should define the method' do
          expect(instance).
            to respond_to(:validate_resource, true).
            with(1).argument
        end # it

        it { expect(instance.send :validate_resource, resource).to be true }

        it 'should clear the errors' do
          previous_errors = Bronze::Errors::Errors.new
          previous_errors[:resources].add :require_more_minerals
          previous_errors[:resources].add :insufficient_vespene_gas

          instance.instance_variable_set :@errors, previous_errors

          instance.send :validate_resource, resource

          expect(instance.errors).to satisfy(&:empty?)
        end # it

        describe 'with a resource that passes validation' do
          before(:example) do
            described_class.contract do
              add_constraint Spec::Constraints::SuccessConstraint.new
            end # contract
          end # before example

          it { expect(instance.send :validate_resource, resource).to be true }

          it 'should clear the errors' do
            previous_errors = Bronze::Errors::Errors.new
            previous_errors[:resources].add :require_more_minerals
            previous_errors[:resources].add :insufficient_vespene_gas

            instance.instance_variable_set :@errors, previous_errors

            instance.send :validate_resource, resource

            expect(instance.errors).to satisfy(&:empty?)
          end # it
        end # describe

        describe 'with a resource that fails validation' do
          before(:example) do
            described_class.contract do
              add_constraint Spec::Constraints::FailureConstraint.new
            end # contract
          end # before example

          it { expect(instance.send :validate_resource, resource).to be false }

          it 'should set the errors' do
            previous_errors = Bronze::Errors::Errors.new
            previous_errors[:resources].add :require_more_minerals
            previous_errors[:resources].add :insufficient_vespene_gas

            instance.instance_variable_set :@errors, previous_errors

            instance.send :validate_resource, resource

            expect(instance.errors.count).to be 1
            expect(instance.errors).to include { |error|
              error.type == Spec::Constraints::FailureConstraint::INVALID_ERROR
            } # end include
          end # it
        end # describe
      end # describe

      describe '#resource' do
        include_examples 'should have reader', :resource, nil
      end # describe
    end # shared_examples
  end # module
end # module
