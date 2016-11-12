# spec/bronze/entities/contracts/entity_contract_spec.rb

require 'bronze/constraints/constraint_builder_examples'
require 'bronze/contracts/contract_examples'
require 'bronze/entities/contracts/entity_contract'

RSpec.describe Bronze::Entities::Contracts::EntityContract do
  include Spec::Constraints::ConstraintBuilderExamples
  include Spec::Contracts::ContractExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Contract methods'

  include_examples 'should implement the EntityConstraintBuilder methods'
end # describe
