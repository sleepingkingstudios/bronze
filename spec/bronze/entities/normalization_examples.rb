# spec/bronze/entities/normalization_examples.rb

require 'bigdecimal'

module Spec::Entities
  module NormalizationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Normalization methods' do
      shared_context 'when the entity class defines many attributes' do
        before(:example) do
          described_class.attribute :name,         String
          described_class.attribute :level,        Integer
          described_class.attribute :happiness,    BigDecimal
          described_class.attribute :capture_odds, Float
          described_class.attribute :captured_at,  DateTime
        end # before example
      end # shared_context

      shared_context 'when the entity has attribute values' do
        let(:attributes) do
          {
            :name         => 'Fierce Dragon Serpent',
            :level        => 50,
            :happiness    => BigDecimal.new('0.5'),
            :capture_odds => 0.05,
            :captured_at  => DateTime.new(1996, 2, 27, 12, 0, 0)
          } # end attributes
        end # let
      end # shared_context

      describe '::denormalize' do
        let(:entity) { described_class.denormalize attributes }
        let(:expected) do
          hsh = {}

          described_class.attributes.each_key do |attr_name|
            hsh[attr_name] = be == attributes[attr_name]
          end # each

          hsh[:id] = be_a(String) if instance.respond_to?(:id)

          hsh
        end # let

        it 'should define the method' do
          expect(described_class).to respond_to(:denormalize).with(1).argument
        end # it

        it 'should return an entity' do
          expect(entity).to be_a described_class

          expected.each do |key, match_expected|
            expect(entity.send key).to match_expected
          end # each
        end # it

        wrap_context 'when the entity class defines many attributes' do
          it 'should return an entity' do
            expect(entity).to be_a described_class

            expected.each do |key, match_expected|
              expect(entity.send key).to match_expected
            end # each
          end # it

          wrap_context 'when the entity has attribute values' do
            it 'should return an entity' do
              expect(entity).to be_a described_class

              expected.each do |key, match_expected|
                expect(entity.send key).to match_expected
              end # each
            end # it
          end # wrap_context
        end # wrap_context
      end # describe

      describe '#normalize' do
        let(:expected) do
          hsh = {}

          described_class.attributes.each_key do |attr_name|
            hsh[attr_name] = attributes[attr_name]
          end # each

          hsh[:id] = instance.id if instance.respond_to?(:id)

          hsh
        end # let

        it { expect(instance).to respond_to(:normalize).with(0).arguments }

        it { expect(instance.normalize).to be == expected }

        wrap_context 'when the entity class defines many attributes' do
          it { expect(instance.normalize).to be == expected }

          wrap_context 'when the entity has attribute values' do
            it { expect(instance.normalize).to be == expected }
          end # wrap_context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
