# spec/bronze/collections/constraints/exists_constraint_spec.rb

require 'bronze/collections/constraints/exists_constraint'
require 'bronze/collections/reference/collection'
require 'bronze/constraints/constraint_examples'

RSpec.describe Bronze::Collections::Constraints::ExistsConstraint do
  include Spec::Constraints::ConstraintExamples

  shared_context 'when a collection is set' do
    let(:instance) { super().with_collection(collection) }
  end # shared_context

  let(:data) do
    [
      {
        'title'  => 'The Fellowship of the Ring',
        'author' => 'J.R.R. Tolkien',
        'series' => 'The Lord of the Rings'
      }, # end hash
      {
        'title'  => 'The Two Towers',
        'author' => 'J.R.R. Tolkien',
        'series' => 'The Lord of the Rings'
      }, # end hash
      {
        'title'  => 'The Return of the King',
        'author' => 'J.R.R. Tolkien',
        'series' => 'The Lord of the Rings'
      } # end hash
    ] # end array
  end # let
  let(:collection) { Bronze::Collections::Reference::Collection.new(data) }
  let(:instance)   { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::DOES_NOT_EXIST_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:DOES_NOT_EXIST_ERROR).
        with_value('constraints.errors.messages.does_not_exist')
    end # it
  end # describe

  describe '::EXISTS_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:EXISTS_ERROR).
        with_value('constraints.errors.messages.exists')
    end # it
  end # describe

  describe '#match' do
    let(:object)       { nil }
    let(:error_type)   { described_class::DOES_NOT_EXIST_ERROR }
    let(:error_params) { { :matching => object } }

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

      describe 'with an empty hash' do
        let(:object) { {} }

        include_examples 'should return true and an empty errors object'
      end # describe

      describe 'with a matching hash' do
        let(:object) { { :author => 'J.R.R. Tolkien' } }

        include_examples 'should return true and an empty errors object'
      end # describe

      describe 'with a non-matching hash' do
        let(:object) { { :author => 'Edgar Rice Burroughs' } }

        include_examples 'should return false and the errors object'
      end # describe
    end # wrap_context
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:object)       { nil }
    let(:error_type)   { described_class::EXISTS_ERROR }
    let(:error_params) { { :matching => object } }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    it 'should require a collection' do
      expect { instance.negated_match nil }.
        to raise_error RuntimeError,
          'specify a collection using the #with_collection method'
    end # it

    wrap_context 'when a collection is set' do
      describe 'with nil' do
        it 'should raise an error' do
          expect { instance.negated_match nil }.
            to raise_error ArgumentError, 'must be a Hash'
        end # it
      end # describe

      describe 'with an empty hash' do
        let(:object) { {} }

        include_examples 'should return false and the errors object'
      end # describe

      describe 'with a matching hash' do
        let(:object) { { :author => 'J.R.R. Tolkien' } }

        include_examples 'should return false and the errors object'
      end # describe

      describe 'with a non-matching hash' do
        let(:object) { { :author => 'Edgar Rice Burroughs' } }

        include_examples 'should return true and an empty errors object'
      end # describe
    end # wrap_context
  end # describe
end # describe
