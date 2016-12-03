# spec/bronze/constraints/contextual_constraint_spec.rb

require 'bronze/constraints/constraint'
require 'bronze/constraints/constraint_examples'
require 'bronze/constraints/contextual_constraint'
require 'bronze/constraints/type_constraint'

RSpec.describe Bronze::Constraints::ContextualConstraint do
  include Spec::Constraints::ConstraintExamples

  shared_context 'when the constraint is negated' do
    let(:params) { super().merge :negated => true }
  end # shared_context

  shared_context 'when a property name is set' do
    let(:property) { :name }
    let(:params)   { super().merge :property => property }
  end # shared_context

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

  describe '#constraint' do
    include_examples 'should have reader', :constraint, ->() { constraint }
  end # describe

  describe '#if_condition' do
    include_examples 'should have reader', :if_condition, nil

    context 'when an if condition is defined' do
      let(:condition) { ->() {} }
      let(:params)    { super().merge :if => condition }

      it { expect(instance.if_condition).to be condition }
    end # context
  end # describe

  describe '#match' do
    let(:object) { { :name => 'Object' } }

    describe 'with an object that matches the constraint' do
      let(:error_type)   { Bronze::Constraints::TypeConstraint::KIND_OF_ERROR }
      let(:error_params) { { :value => Hash } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(Hash) }

      include_examples 'should return true and an empty errors object'

      wrap_context 'when the constraint is negated' do
        include_examples 'should return false and the errors object'
      end # wrap_context
    end # describe

    describe 'with an object that does not match the constraint' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }

      include_examples 'should return false and the errors object'

      wrap_context 'when the constraint is negated' do
        include_examples 'should return true and an empty errors object'
      end # wrap_context

      context 'with a matching if conditional with no parameters' do
        let(:params) do
          super().merge :if => ->() { true }
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a matching if conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :if => lambda { |obj|
            example.expect(obj).to example.be(expected)

            true
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a matching if conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :if => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            true
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching if conditional with no parameters' do
        let(:params) do
          super().merge :if => ->() { false }
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching if conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :if => lambda { |obj|
            example.expect(obj).to example.be(expected)

            false
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching if conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :if => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            false
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching unless conditional with no parameters' do
        let(:params) do
          super().merge :unless => ->() { true }
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching unless conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :unless => lambda { |obj|
            example.expect(obj).to example.be(expected)

            true
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching unless conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :unless => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            true
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching unless conditional with no parameters' do
        let(:params) do
          super().merge :unless => ->() { false }
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching unless conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :unless => lambda { |obj|
            example.expect(obj).to example.be(expected)

            false
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching unless conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :unless => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            false
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context
    end # describe

    wrap_context 'when a property name is set' do
      describe 'with an object that does not define the property' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { double('object') }

        include_examples 'should return false and the errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return true and an empty errors object'
        end # wrap_context
      end # describe

      describe 'with an object that matches the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { double('object', :name => 'Object') }

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return false and the errors object'
        end # wrap_context
      end # describe

      describe 'with an object that does not match the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => Symbol } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(Symbol) }
        let(:object)       { double('object', :name => 'Object') }

        include_examples 'should return false and the errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return true and an empty errors object'
        end # wrap_context

        context 'with a matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context

        context 'with a non-matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a non-matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context
      end # describe

      describe 'with a hash that does not have the key' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { {} }

        include_examples 'should return false and the errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return true and an empty errors object'
        end # wrap_context
      end # describe

      describe 'with a hash that matches the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { { :name => 'Object' } }

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return false and the errors object'
        end # wrap_context
      end # describe

      describe 'with an object that does not match the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => Symbol } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(Symbol) }
        let(:object)       { { :name => 'Object' } }

        include_examples 'should return false and the errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return true and an empty errors object'
        end # wrap_context

        context 'with a matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context

        context 'with a non-matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a non-matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context
      end # describe
    end # wrap_context
  end # describe

  describe '#negated' do
    include_examples 'should have reader', :negated, false

    wrap_context 'when the constraint is negated' do
      it { expect(instance.negated).to be true }
    end # wrap_context
  end # describe

  describe '#negated?' do
    include_examples 'should have predicate', :negated?, false

    wrap_context 'when the constraint is negated' do
      it { expect(instance.negated?).to be true }
    end # wrap_context
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:object)       { { :name => 'Object' } }

    describe 'with an object that matches the constraint' do
      let(:error_type)   { Bronze::Constraints::TypeConstraint::KIND_OF_ERROR }
      let(:error_params) { { :value => Hash } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(Hash) }

      include_examples 'should return false and the errors object'

      wrap_context 'when the constraint is negated' do
        include_examples 'should return true and an empty errors object'
      end # wrap_context

      context 'with a matching if conditional with no parameters' do
        let(:params) do
          super().merge :if => ->() { true }
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a matching if conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :if => lambda { |obj|
            example.expect(obj).to example.be(expected)

            true
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a matching if conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :if => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            true
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching if conditional with no parameters' do
        let(:params) do
          super().merge :if => ->() { false }
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching if conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :if => lambda { |obj|
            example.expect(obj).to example.be(expected)

            false
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching if conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :if => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            false
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching unless conditional with no parameters' do
        let(:params) do
          super().merge :unless => ->() { true }
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching unless conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :unless => lambda { |obj|
            example.expect(obj).to example.be(expected)

            true
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a matching unless conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :unless => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            true
          } # end lambda
        end # let

        include_examples 'should return true and an empty errors object'
      end # context

      context 'with a non-matching unless conditional with no parameters' do
        let(:params) do
          super().merge :unless => ->() { false }
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching unless conditional with one parameter' do
        let(:params) do
          example  = self
          expected = object

          super().merge :unless => lambda { |obj|
            example.expect(obj).to example.be(expected)

            false
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context

      context 'with a non-matching unless conditional with two parameters' do
        let(:params) do
          example  = self
          expected = [object, nil]

          super().merge :unless => lambda { |obj, prop|
            example.expect([obj, prop]).to example.be == expected

            false
          } # end lambda
        end # let

        include_examples 'should return false and the errors object'
      end # context
    end # describe

    describe 'with an object that does not match the constraint' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:error_params) { { :value => String } }
      let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }

      include_examples 'should return true and an empty errors object'

      wrap_context 'when the constraint is negated' do
        include_examples 'should return false and the errors object'
      end # wrap_context
    end # describe

    wrap_context 'when a property name is set' do
      describe 'with an object that does not define the property' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { double('object') }

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return false and the errors object'
        end # wrap_context
      end # describe

      describe 'with an object that matches the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { double('object', :name => 'Object') }

        include_examples 'should return false and the errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return true and an empty errors object'
        end # wrap_context

        context 'with a matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context

        context 'with a non-matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a non-matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context
      end # describe

      describe 'with an object that does not match the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => Symbol } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(Symbol) }
        let(:object)       { double('object', :name => 'Object') }

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return false and the errors object'
        end # wrap_context
      end # describe

      describe 'with a hash that does not have the key' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { {} }

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return false and the errors object'
        end # wrap_context
      end # describe

      describe 'with a hash that matches the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => String } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(String) }
        let(:object)       { { :name => 'Object' } }

        include_examples 'should return false and the errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return true and an empty errors object'
        end # wrap_context

        context 'with a matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context

        context 'with a non-matching if conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :if => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              true
            } # end lambda
          end # let

          include_examples 'should return true and an empty errors object'
        end # context

        context 'with a non-matching unless conditional with two parameters' do
          let(:params) do
            example  = self
            expected = [object, property]

            super().merge :unless => lambda { |obj, prop|
              example.expect([obj, prop]).to example.be == expected

              false
            } # end lambda
          end # let

          include_examples 'should return false and the errors object'
        end # context
      end # describe

      describe 'with an object that does not match the constraint' do
        let(:error_type) do
          Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
        end # let
        let(:error_params) { { :value => Symbol } }
        let(:constraint)   { Bronze::Constraints::TypeConstraint.new(Symbol) }
        let(:object)       { { :name => 'Object' } }

        include_examples 'should return true and an empty errors object'

        wrap_context 'when the constraint is negated' do
          include_examples 'should return false and the errors object'
        end # wrap_context
      end # describe
    end # wrap_context
  end # describe

  describe '#property' do
    include_examples 'should have reader', :property, nil

    wrap_context 'when a property name is set' do
      it { expect(instance.property).to be == property }
    end # wrap_context
  end # describe

  describe '#unless_condition' do
    include_examples 'should have reader', :unless_condition, nil

    context 'when an unless conditional is defined' do
      let(:conditional) { ->() {} }
      let(:params)      { super().merge :unless => conditional }

      it { expect(instance.unless_condition).to be conditional }
    end # context
  end # describe
end # describe
