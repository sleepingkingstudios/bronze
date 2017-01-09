# spec/bronze/entities/primary_key_examples.rb

require 'bronze/entities/attributes/attributes_examples'

module Spec::Entities::PrimaryKeyExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
  include Spec::Entities::Attributes::AttributesExamples

  shared_examples 'should implement the PrimaryKey methods' do
    describe '::KEY_DEFAULT' do
      it 'should define the constant' do
        expect(described_class).to have_constant :KEY_DEFAULT
      end # it

      it 'should generate new ULID objects' do
        default = described_class::KEY_DEFAULT

        expect(default).to be_a Proc

        first  = default.call
        second = default.call

        # rubocop:disable Style/CaseEquality
        expect(Bronze::Entities::Ulid).to be === first
        expect(Bronze::Entities::Ulid).to be === second
        # rubocop:enable Style/CaseEquality

        expect(second).to be > first
      end # it
    end # describe

    describe '::KEY_TYPE' do
      it 'should define the constant' do
        expect(described_class).to have_constant(:KEY_TYPE).with_value(String)
      end # it
    end # describe

    describe '#id' do
      include_examples 'should define attribute',
        :id,
        Bronze::Entities::Ulid,
        :read_only => true

      it 'should generate a ULID' do
        ulid = instance.id

        # rubocop:disable Style/CaseEquality
        expect(Bronze::Entities::Ulid).to be === ulid
        # rubocop:enable Style/CaseEquality
      end # it

      it 'should be consistent' do
        ids = Array.new(3) { instance.id }.uniq

        expect(ids.length).to be 1
      end # it
    end # describe
  end # shared_examples
end # module
