# spec/bronze/entities/uniqueness_examples.rb

require 'bronze/collections/reference/collection'

module Spec::Entities
  module UniquenessExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Uniqueness methods' do
      shared_context 'when the entity defines a uniqueness constraint' do
        before(:example) do
          entity_class.attribute :title, String

          entity_class.unique :title
        end # before example
      end # shared_context

      shared_context 'when the entity defines a scoped uniqueness constraint' do
        before(:example) do
          entity_class.attribute :title,  String
          entity_class.attribute :author, String

          entity_class.unique :title, :author
        end # before example
      end # shared_context

      describe '::unique' do
        it 'should define the class method' do
          expect(described_class).
            to respond_to(:unique).
            with(1).argument.
            and_unlimited_arguments
        end # it

        describe 'with an attribute' do
          before(:example) do
            entity_class.attribute :title, String
          end # before example

          it 'should define a uniqueness constraint on the attribute' do
            constraints = described_class.send :uniqueness_constraints

            expect { described_class.unique :title }.
              to change(constraints, :count).by(1)

            expect(constraints.last).
              to be_a Bronze::Entities::Constraints::UniquenessConstraint
            expect(constraints.last.attributes).to be == [:title]
          end # it
        end # describe

        describe 'with many attributes' do
          before(:example) do
            entity_class.attribute :title,  String
            entity_class.attribute :author, String
          end # before example

          it 'should define a uniqueness constraint on the attribute' do
            constraints = described_class.send :uniqueness_constraints

            expect { described_class.unique :title, :author }.
              to change(constraints, :count).by(1)

            expect(constraints.last).
              to be_a Bronze::Entities::Constraints::UniquenessConstraint
            expect(constraints.last.attributes).to be == [:title, :author]
          end # it
        end # describe
      end # describe

      describe '::uniqueness_constraints' do
        it 'should define the private class reader' do
          expect(described_class).not_to respond_to(:uniqueness_constraints)

          expect(described_class).
            to respond_to(:uniqueness_constraints, true).
            with(0).arguments
        end # it

        it { expect(described_class.send :uniqueness_constraints).to be == [] }
      end # describe

      describe '#match_uniqueness' do
        shared_examples 'should return true and an empty errors object' do
          describe 'should return true and an empty errors object' do
            it do
              result, errors = instance.match_uniqueness(collection)

              expect(result).to be true
              expect(errors).to satisfy(&:empty?)
            end # it
          end # describe
        end # shared_examples

        shared_examples 'should return false and the errors object' do
          describe 'should return false and the errors object' do
            it do
              result, errors = instance.match_uniqueness(collection)

              expect(result).to be false

              expected_error = { :type => error_type, :params => error_params }

              expect(errors).to include(expected_error)
            end # it
          end # describe
        end # shared_examples

        let(:data) do
          [
            {
              :id     => '0',
              :title  => 'The Fellowship of the Ring',
              :author => 'J.R.R. Tolkien',
              :series => 'The Lord of the Rings'
            }, # end hash
            {
              :id     => '1',
              :title  => 'The Two Towers',
              :author => 'J.R.R. Tolkien',
              :series => 'The Lord of the Rings'
            }, # end hash
            {
              :id     => '2',
              :title  => 'The Return of the King',
              :author => 'J.R.R. Tolkien',
              :series => 'The Lord of the Rings'
            } # end hash
          ] # end array
        end # let
        let(:collection) do
          Bronze::Collections::Reference::Collection.new(data)
        end # let
        let(:error_type) do
          Bronze::Entities::Constraints::UniquenessConstraint::NOT_UNIQUE_ERROR
        end # let
        let(:matching)     { { :title => 'The Fellowship of the Ring' } }
        let(:error_params) { { :matching => matching } }

        it 'should define the method' do
          expect(instance).to respond_to(:match_uniqueness).with(1).argument
        end # it

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the entity defines a uniqueness constraint' do
          include_examples 'should return true and an empty errors object'

          context 'when the collection includes the entity' do
            let(:attributes) { data.first }

            include_examples 'should return true and an empty errors object'
          end # context

          context 'when the collection includes a matching entity' do
            let(:attributes) { data.first.merge :id => '3' }

            include_examples 'should return false and the errors object'
          end # context
        end # wrap_context

        wrap_context 'when the entity defines a scoped uniqueness constraint' do
          include_examples 'should return true and an empty errors object'

          context 'when the collection includes the entity' do
            let(:attributes) { data.first }

            include_examples 'should return true and an empty errors object'
          end # context

          context 'when the collection includes a partially matching entity' do
            let(:attributes) do
              data.first.merge :author => 'John Ronald Reuel Tolkien'
            end # let

            include_examples 'should return true and an empty errors object'
          end # context

          context 'when the collection includes a matching entity' do
            let(:attributes) { data.first.merge :id => '3' }
            let(:matching) do
              {
                :title  => 'The Fellowship of the Ring',
                :author => 'J.R.R. Tolkien'
              } # end matching
            end # let

            include_examples 'should return false and the errors object'
          end # context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
