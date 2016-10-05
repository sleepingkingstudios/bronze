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
                error.type == error_type && error.params == [attr_type]
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
                error.type == error_type && error.params == [attr_type]
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
    end # describe
  end # describe
end # describe
