# spec/bronze/entities/constraints/attribute_types_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/type_constraint'
require 'bronze/entities/constraints/attribute_types_constraint'
require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Constraints::AttributeTypesConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::MISSING_ATTRIBUTES_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:MISSING_ATTRIBUTES_ERROR).
        with_value('constraints.errors.missing_attributes')
    end # it
  end # describe

  describe '#match' do
    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with nil' do
      let(:error_type) { described_class::MISSING_ATTRIBUTES_ERROR }
      let(:object)     { nil }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an object' do
      let(:error_type) { described_class::MISSING_ATTRIBUTES_ERROR }
      let(:object)     { Object.new }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an entity' do
      let(:error_type) do
        Bronze::Constraints::TypeConstraint::NOT_KIND_OF_ERROR
      end # let
      let(:attribute_definitions) do
        {
          :title  => { :type => String },
          :volume => { :type => Integer }
        } # end hash
      end # let
      let(:entity_class) { Spec::ArchivedPeriodical }
      let(:attributes)   { {} }
      let(:object)       { entity_class.new attributes }

      options = { :base_class => Bronze::Entities::Entity }
      mock_class Spec, :ArchivedPeriodical, options do |klass|
        attribute_definitions.each do |attribute_name, attribute_config|
          attribute_type = attribute_config[:type]
          attribute_opts = attribute_config[:opts] || {}

          klass.attribute attribute_name, attribute_type, **attribute_opts
        end # each
      end # mock_class

      describe 'with nil attributes' do
        include_examples 'should return false and the errors object',
          lambda { |errors|
            expect(errors[:id]).to satisfy(&:empty?)

            attribute_definitions.each do |attr_name, attr_config|
              attr_type = attr_config[:type]

              expect(errors[attr_name]).to include { |error|
                error.type == error_type &&
                  error.params == { :type => attr_type }
              } # end include
            end # each
          } # end lambda

        context 'when the attributes allow nil values' do
          let(:attribute_definitions) do
            super().tap do |hsh|
              hsh.each do |_, config|
                (config[:opts] ||= {}).update :allow_nil => true
              end # each
            end # tap
          end # let

          include_examples 'should return true and an empty errors object'
        end # context
      end # describe

      describe 'with attributes with invalid values' do
        let(:attributes) do
          super().merge(
            :title  => ['The Hobbit', 'An Unexpected Journey'],
            :volume => 'XVII'
          ) # end merge
        end # let

        include_examples 'should return false and the errors object',
          lambda { |errors|
            expect(errors[:id]).to satisfy(&:empty?)

            attribute_definitions.each do |attr_name, attr_config|
              attr_type = attr_config[:type]

              expect(errors[attr_name]).to include { |error|
                error.type == error_type &&
                  error.params == { :type => attr_type }
              } # end include
            end # each
          } # end lambda
      end # describe

      describe 'with attributes with valid values' do
        let(:attributes) do
          super().merge :title => 'The Silmarillion', :volume => 13
        end # let

        include_examples 'should return true and an empty errors object'
      end # describe

      context 'when the entity has an Array attribute' do
        let(:attributes) do
          super().merge :title => 'The Silmarillion', :volume => 13
        end # let
        let(:attribute_definitions) do
          super().merge :tags => { :type => Array[String] }
        end # let
        let(:error_nesting) { :tags }

        describe 'with a scalar attribute value' do
          let(:attributes)    { super().merge :tags => 'None' }
          let(:error_params)  { { :type => Array } }

          include_examples 'should return false and the errors object'
        end # describe

        describe 'with an empty array' do
          let(:attributes) { super().merge :tags => [] }

          include_examples 'should return true and an empty errors object'
        end # describe

        describe 'with an array with invalid items' do
          let(:attributes)   { super().merge :tags => [1, 2, 3] }
          let(:error_params) { { :type => String } }

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 3

              0.upto(2) do |index|
                nested = errors[error_nesting][index]
                error  = nested.to_a.first

                expect(nested.count).to be 1

                expect(error).to be_a Bronze::Errors::Error
                expect(error.type).to be error_type
                expect(error.params).to be == error_params
                expect(error.nesting).to be == [error_nesting, index]
              end # upto
            } # end lambda
        end # describe

        describe 'with an array with valid items' do
          let(:attributes) { super().merge :tags => %w(ichi ni san) }

          include_examples 'should return true and an empty errors object'
        end # describe

        describe 'with an array with mixed valid and invalid items' do
          let(:attributes)   { super().merge :tags => [:uno, 'ni', 3] }
          let(:error_params) { { :type => String } }

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 2

              [0, 2].each do |index|
                nested = errors[error_nesting][index]
                error  = nested.to_a.first

                expect(nested.count).to be 1

                expect(error).to be_a Bronze::Errors::Error
                expect(error.type).to be error_type
                expect(error.params).to be == error_params
                expect(error.nesting).to be == [error_nesting, index]
              end # each
            } # end lambda
        end # describe
      end # context

      context 'when the entity has a Hash attribute' do
        let(:attributes) do
          super().merge :title => 'The Silmarillion', :volume => 13
        end # let
        let(:attribute_definitions) do
          super().merge :citations => { :type => Hash[Symbol, String] }
        end # let

        describe 'with a scalar attribute value' do
          let(:attributes)    { super().merge :citations => 'None' }
          let(:error_params)  { { :type => Hash } }
          let(:error_nesting) { :citations }

          include_examples 'should return false and the errors object'
        end # describe

        describe 'with an empty hash' do
          let(:attributes) { super().merge :citations => {} }

          include_examples 'should return true and an empty errors object'
        end # describe

        describe 'with a hash with invalid keys' do
          let(:citations)     { { 0 => 'Cero', 1 => 'Uno', 2 => 'Dos' } }
          let(:attributes)    { super().merge :citations => citations }
          let(:error_params)  { { :type => Symbol } }
          let(:error_nesting) { :citations }

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 3

              0.upto(2) do |key|
                nested = errors[error_nesting][key]
                error  = nested.to_a.first

                expect(nested.count).to be 1

                expect(error).to be_a Bronze::Errors::Error
                expect(error.type).to be error_type
                expect(error.params).to be == error_params
                expect(error.nesting).to be == [error_nesting, key]
              end # upto
            } # end lambda
        end # describe

        describe 'with a hash with invalid values' do
          let(:citations)     { { :ichi => 1, :ni => 2, :san => 3 } }
          let(:attributes)    { super().merge :citations => citations }
          let(:error_params)  { { :type => String } }
          let(:error_nesting) { :citations }

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 3

              [:ichi, :ni, :san].each do |key|
                nested = errors[error_nesting][key]
                error  = nested.to_a.first

                expect(nested.count).to be 1

                expect(error).to be_a Bronze::Errors::Error
                expect(error.type).to be error_type
                expect(error.params).to be == error_params
                expect(error.nesting).to be == [error_nesting, key]
              end # upto
            } # end lambda
        end # describe

        describe 'with a hash with mixed valid and invalid keys and values' do
          let(:citations)     { { :ichi => 1, :ni => 'ni', 3 => 'san' } }
          let(:attributes)    { super().merge :citations => citations }
          let(:error_params)  { { :type => String } }
          let(:error_nesting) { :citations }

          include_examples 'should return false and the errors object',
            lambda { |errors|
              expect(errors.count).to be 2

              { :ichi => String, 3 => Symbol }.each do |key, type|
                nested = errors[error_nesting][key]
                error  = nested.to_a.first

                expect(nested.count).to be 1

                expect(error).to be_a Bronze::Errors::Error
                expect(error.type).to be error_type
                expect(error.params).to be == { :type => type }
                expect(error.nesting).to be == [error_nesting, key]
              end # each
            } # end lambda
        end # describe

        describe 'with a hash with valid keys and values' do
          let(:citations)  { { :ichi => 'ichi', :ni => 'ni', :san => 'san' } }
          let(:attributes) { super().merge :citations => citations }

          include_examples 'should return true and an empty errors object'
        end # describe
      end # context
    end # describe
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
