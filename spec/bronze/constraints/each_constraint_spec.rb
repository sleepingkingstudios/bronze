# spec/bronze/constraints/each_constraint_spec.rb

require 'bronze/constraints/contextual_constraint_examples'
require 'bronze/constraints/each_constraint'
require 'bronze/constraints/type_constraint'

RSpec.describe Bronze::Constraints::EachConstraint do
  include Spec::Constraints::ContextualConstraintExamples

  shared_examples 'should apply if or unless conditional' do
    desc = 'with a conditional with one parameter'
    shared_context desc do |conditional:, matching:|
      let(:params) do
        example = self
        values  = object.is_a?(Array) ? object.each : object.each_value

        super().merge conditional => lambda { |val|
          example.expect(val).to example.be(values.next)

          matching
        } # end lambda
      end # let
    end # shared_context

    desc = 'with a conditional with three parameters'
    shared_context desc do |conditional:, matching:|
      let(:params) do
        example    = self
        collection = object

        if object.is_a?(Array)
          keys   = 0.upto(object.count - 1)
          values = object.each
        else
          keys   = object.each_key
          values = object.each_value
        end # if-else

        super().merge conditional => lambda { |val, key, col|
          example.expect(val).to example.be(values.next)
          example.expect(key).to example.be(keys.next)
          example.expect(col).to example.be(collection)

          matching
        } # end lambda
      end # let
    end # shared_context

    desc = 'with a conditional with four parameters'
    shared_context desc do |conditional:, matching:|
      let(:property) { defined?(super) ? super() : nil }
      let(:params) do
        example    = self
        collection = object
        pname      = property

        if object.is_a?(Array)
          keys   = 0.upto(object.count - 1)
          values = object.each
        else
          keys   = object.each_key
          values = object.each_value
        end # if-else

        super().merge conditional => lambda { |val, key, col, prop|
          example.expect(val).to  example.be(values.next)
          example.expect(key).to  example.be(keys.next)
          example.expect(col).to  example.be(collection)
          example.expect(prop).to example.be(pname)

          matching
        } # end lambda
      end # let
    end # shared_context

    context 'with a matching if conditional with no parameters' do
      let(:params) do
        super().merge :if => ->() { true }
      end # let

      include_examples 'should return false and the errors object'
    end # context

    context 'with a matching if conditional with one parameter' do
      include_context 'with a conditional with one parameter',
        :conditional => :if,
        :matching    => true

      include_examples 'should return false and the errors object'
    end # context

    context 'with a matching if conditional with three parameters' do
      include_context 'with a conditional with three parameters',
        :conditional => :if,
        :matching    => true

      include_examples 'should return false and the errors object'
    end # context

    context 'with a matching if conditional with four parameters' do
      include_context 'with a conditional with four parameters',
        :conditional => :if,
        :matching    => true

      include_examples 'should return false and the errors object'
    end # context

    context 'with a non-matching if conditional with no parameters' do
      let(:params) do
        super().merge :if => ->() { false }
      end # let

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a non-matching if conditional with one parameter' do
      include_context 'with a conditional with one parameter',
        :conditional => :if,
        :matching    => false

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a non-matching if conditional with three parameters' do
      include_context 'with a conditional with three parameters',
        :conditional => :if,
        :matching    => false

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a non-matching if conditional with four parameters' do
      include_context 'with a conditional with four parameters',
        :conditional => :if,
        :matching    => false

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a matching unless conditional with no parameters' do
      let(:params) do
        super().merge :unless => ->() { true }
      end # let

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a matching unless conditional with one parameter' do
      include_context 'with a conditional with one parameter',
        :conditional => :unless,
        :matching    => true

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a matching unless conditional with three parameters' do
      include_context 'with a conditional with three parameters',
        :conditional => :unless,
        :matching    => true

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a matching unless conditional with four parameters' do
      include_context 'with a conditional with four parameters',
        :conditional => :unless,
        :matching    => true

      include_examples 'should return true and an empty errors object'
    end # context

    context 'with a non-matching unless conditional with no parameters' do
      let(:params) do
        super().merge :unless => ->() { false }
      end # let

      include_examples 'should return false and the errors object'
    end # context

    context 'with a non-matching unless conditional with one parameter' do
      include_context 'with a conditional with one parameter',
        :conditional => :unless,
        :matching    => false

      include_examples 'should return false and the errors object'
    end # context

    context 'with a non-matching unless conditional with three parameters' do
      include_context 'with a conditional with three parameters',
        :conditional => :unless,
        :matching    => false

      include_examples 'should return false and the errors object'
    end # context

    context 'with a non-matching unless conditional with four parameters' do
      include_context 'with a conditional with four parameters',
        :conditional => :unless,
        :matching    => false

      include_examples 'should return false and the errors object'
    end # context

    context 'with a partially matching if conditional' do
      let(:params) do
        counter = 0.upto(object.count).each

        super().merge :if => ->() { counter.next.even? }
      end # let

      include_examples 'should return false and the errors object',
        ->(errors) { expect(errors.count).to be == object.count / 2 }
    end # context

    context 'with a partially matching unless conditional' do
      let(:params) do
        counter = 0.upto(object.count).each

        super().merge :unless => ->() { counter.next.even? }
      end # let

      include_examples 'should return false and the errors object',
        ->(errors) { expect(errors.count).to be == object.count / 2 }
    end # context
  end # shared_examples

  let(:constraint) { double('constraint') }
  let(:params)     { {} }
  let(:instance)   { described_class.new(constraint, **params) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(1).argument.
        and_keywords(:negated, :property).
        and_any_keywords
    end # it
  end # describe

  describe '::NOT_A_COLLECTION_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NOT_A_COLLECTION_ERROR).
        with_value('constraints.errors.messages.not_a_collection')
    end # it
  end # describe

  include_examples 'should implement the ContextualConstraint methods'

  describe '#match' do
    describe 'with nil' do
      let(:object)     { nil }
      let(:error_type) { described_class::NOT_A_COLLECTION_ERROR }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an object' do
      let(:object)     { Object.new }
      let(:error_type) { described_class::NOT_A_COLLECTION_ERROR }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an empty array' do
      let(:object) { [] }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an array with non-matching items' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)       { [0, 1, 2, 3] }

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [0, 1, 2].each do |index|
            nesting = errors[index]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [index]
          end # each
        } # end lambda

      include_examples 'should apply if or unless conditional'
    end # describe

    describe 'with an array with matching items' do
      let(:constraint) { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)     { %w(ichi ni san) }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a mixed array with matching and non-matching items' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)       { ['ichi', 'ni', 'san', 'yon', 5, 6, 7, 8] }

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [4, 5, 6, 7].each do |index|
            nesting = errors[index]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [index]
          end # each
        } # end lambda
    end # describe

    describe 'with an empty hash' do
      let(:object) { {} }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a hash with non-matching values' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)       { { :ichi => 1, :ni => 2, :san => 3, :yon => 4 } }

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [:ichi, :ni, :san, :yon].each do |key|
            nesting = errors[key]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [key]
          end # each
        } # end lambda

      include_examples 'should apply if or unless conditional'
    end # describe

    describe 'with a hash with matching values' do
      let(:constraint) { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)     { { :ichi => 'uno', :ni => 'dos', :san => 'tres' } }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a mixed hash with matching and non-matching values' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object) do
        {
          :ichi  => 'uno',
          :ni    => 'dos',
          :san   => 'tres',
          :yon   => 'cuatro',
          :go    => 5,
          :roku  => 6,
          :hachi => 7,
          :nana  => 8
        } # end hash
      end # let

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [:go, :roku, :hachi, :nana].each do |key|
            nesting = errors[key]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [key]
          end # each
        } # end lambda
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }

    describe 'with nil' do
      let(:object)     { nil }
      let(:error_type) { described_class::NOT_A_COLLECTION_ERROR }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an object' do
      let(:object)     { Object.new }
      let(:error_type) { described_class::NOT_A_COLLECTION_ERROR }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an empty array' do
      let(:object) { [] }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an array with non-matching items' do
      let(:constraint) { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)     { [0, 1, 2] }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an array with matching items' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)       { %w(ichi ni san yon) }

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [0, 1, 2, 3].each do |index|
            nesting = errors[index]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [index]
          end # each
        } # end lambda

      include_examples 'should apply if or unless conditional'
    end # describe

    describe 'with a mixed array with matching and non-matching items' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)       { ['ichi', 'ni', 'san', 'yon', 5, 6, 7, 8] }

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [0, 1, 2, 3].each do |index|
            nesting = errors[index]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [index]
          end # each
        } # end lambda
    end # describe

    describe 'with an empty hash' do
      let(:object) { {} }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a hash with non-matching values' do
      let(:constraint) { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object)     { { :ichi => 1, :ni => 2, :san => 3 } }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a hash with matching values' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object) do
        { :ichi => 'uno', :ni => 'dos', :san => 'tres', :yon => 'cuatro' }
      end # let

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [:ichi, :ni, :san].each do |key|
            nesting = errors[key]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [key]
          end # each
        } # end lambda

      include_examples 'should apply if or unless conditional'
    end # describe

    describe 'with a mixed hash with matching and non-matching values' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
      let(:object) do
        {
          :ichi  => 'uno',
          :ni    => 'dos',
          :san   => 'tres',
          :yon   => 'cuatro',
          :go    => 5,
          :roku  => 6,
          :hachi => 7,
          :nana  => 8
        } # end hash
      end # let

      include_examples 'should return false and the errors object',
        lambda { |errors|
          expect(errors.count).to be 4

          [:ichi, :ni, :san].each do |key|
            nesting = errors[key]

            expect(nesting).to be_a Bronze::Errors::Errors
            expect(nesting.count).to be 1

            error = nesting.to_a.first
            expect(error).to be_a Bronze::Errors::Error
            expect(error.type).to be == error_type
            expect(error.params).to be == error_params
            expect(error.nesting).to be == [key]
          end # each
        } # end lambda
    end # describe
  end # describe
end # describe
