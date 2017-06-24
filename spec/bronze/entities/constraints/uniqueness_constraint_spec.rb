# spec/bronze/entities/constraints/uniqueness_constraint_spec.rb

require 'bronze/collections/reference/collection'
require 'bronze/constraints/constraint_examples'
require 'bronze/entities/constraints/uniqueness_constraint'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Constraints::UniquenessConstraint do
  include Spec::Constraints::ConstraintExamples

  shared_context 'when a collection is set' do
    let(:instance) { super().with_collection(collection) }
  end # shared_context

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
  let(:collection) { Bronze::Collections::Reference::Collection.new(data) }
  let(:attributes) { %w(title) }
  let(:instance)   { described_class.new(*attributes) }

  example_class 'Spec::Book', :base_class => Bronze::Entities::Entity do |klass|
    klass.attribute :title,  String
    klass.attribute :author, String
    klass.attribute :series, String
  end # example_class

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(1).argument.
        and_unlimited_arguments
    end # it
  end # describe

  describe '::NOT_UNIQUE_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NOT_UNIQUE_ERROR).
        with_value('constraints.errors.messages.not_unique')
    end # it
  end # describe

  describe '#attributes' do
    include_examples 'should have reader',
      :attributes,
      ->() { be == attributes }
  end # describe

  describe '#match' do
    let(:object)       { nil }
    let(:matching)     { nil }
    let(:error_type)   { described_class::NOT_UNIQUE_ERROR }
    let(:error_params) { { :matching => matching } }

    it { expect(instance).to respond_to(:match).with(1).argument }

    it 'should require a collection' do
      expect { instance.match nil }.
        to raise_error RuntimeError,
          'specify a collection using the #with_collection method'
    end # it

    wrap_context 'when a collection is set' do
      describe 'with nil' do
        it 'should raise an error' do
          expect { instance.match nil }.
            to raise_error ArgumentError, 'must be a Hash'
        end # it
      end # describe

      describe 'with a non-matching entity' do
        let(:object) do
          Spec::Book.new(
            :title  => 'The Hobbit',
            :author => 'J.R.R. Tolkien',
            :series => 'The Lord of the Rings'
          ) # end book
        end # let

        include_examples 'should return true and an empty errors object'
      end # describe

      describe 'with a matching entity with matching id' do
        let(:object) { Spec::Book.new(data.first) }

        include_examples 'should return true and an empty errors object'
      end # describe

      describe 'with a matching entity with non-matching id' do
        let(:object) do
          Spec::Book.new(data.first.merge(:id => '3'))
        end # let
        let(:matching) { { :title => 'The Fellowship of the Ring' } }

        include_examples 'should return false and the errors object'
      end # describe

      context 'when the uniqueness constraint is scoped to many attributes' do
        let(:attributes) { %w(title author) }

        describe 'with a non-matching entity' do
          let(:object) do
            Spec::Book.new(
              :title  => 'The Lion, The Witch, And The Wardrobe',
              :author => 'C. S. Lewis',
              :series => 'The Chronicles of Narnia'
            ) # end book
          end # let

          include_examples 'should return true and an empty errors object'
        end # describe

        describe 'with a partially matching entity' do
          let(:object) do
            Spec::Book.new(
              :title  => 'The Fellowship of the Ring',
              :author => 'John Ronald Reuel Tolkien',
              :series => 'The Lord of the Rings'
            ) # end book
          end # let

          include_examples 'should return true and an empty errors object'
        end # describe

        describe 'with a matching entity with matching id' do
          let(:object) { Spec::Book.new(data.first) }

          include_examples 'should return true and an empty errors object'
        end # describe

        describe 'with a matching entity with non-matching id' do
          let(:object) do
            Spec::Book.new(data.first.merge(:id => '3'))
          end # let
          let(:matching) do
            {
              :title  => 'The Fellowship of the Ring',
              :author => 'J.R.R. Tolkien'
            } # end matching
          end # let

          include_examples 'should return false and the errors object'
        end # describe
      end # context
    end # wrap_context
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    it 'should raise an error' do
      expect { instance.negated_match nil }.
        to raise_error Bronze::Constraints::Constraint::InvalidNegationError,
          "#{described_class.name} constraints do not support negated matching"
    end # it
  end # describe
end # describe
