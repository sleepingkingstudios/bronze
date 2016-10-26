# spec/bronze/entities/contracts/entity_contract_spec.rb

require 'bronze/contracts/type_contract_examples'
require 'bronze/entities/contracts/entity_contract'

RSpec.describe Bronze::Entities::Contracts::EntityContract do
  include Spec::Contracts::TypeContractExamples

  let(:described_class) do
    klass = Class.new
    klass.send :include, super()
    klass
  end # let

  include_examples 'should implement the TypeContract methods'

  describe '::contract' do
    describe 'with a block' do
      describe 'with a #constrain_attribute_types call' do
        it 'should add the specified constraints' do
          contract = described_class.contract do
            constrain_attribute_types

            constrain :title, :present => true

            constrain :isbn, :type => String, :nil => false
          end # contract

          constraints = contract.constraints

          expect(constraints).to include { |data|
            constraint_type =
              Bronze::Entities::Constraints::AttributeTypesConstraint

            data.constraint.is_a?(constraint_type) &&
              data.nesting == [] &&
              !data.negated?
          } # end include

          expect(constraints).to include { |data|
            data.constraint.is_a?(Bronze::Constraints::PresenceConstraint) &&
              data.nesting == [:title] &&
              !data.negated?
          } # end include

          expect(constraints).to include { |data|
            data.constraint.is_a?(Bronze::Constraints::TypeConstraint) &&
              data.constraint.type == String &&
              data.nesting == [:isbn] &&
              !data.negated?
          } # end include

          expect(constraints).to include { |data|
            data.constraint.is_a?(Bronze::Constraints::NilConstraint) &&
              data.nesting == [:isbn] &&
              data.negated?
          } # end include
        end # it
      end # describe
    end # describe
  end # describe
end # describe
