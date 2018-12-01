# spec/bronze/entities/normalization/normalization_examples.rb

require 'bigdecimal'

require 'bronze/entities/attributes/dirty_tracking'

module Spec::Entities
  module Normalization; end
end # module

module Spec::Entities::Normalization
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
        let(:normalized) do
          attributes.merge(
            :happiness   => attributes[:happiness].to_s,
            :captured_at => attributes[:captured_at].strftime('%FT%T%z')
          ) # end normalized
        end # let
      end # shared_context

      describe '::denormalize' do
        let(:entity) { described_class.denormalize normalized }
        let(:normalized) { attributes }
        let(:expected) do
          hsh = {}

          described_class.attributes.each do |attr_name, _metadata|
            hsh[attr_name] = be == attributes[attr_name]
          end # each

          hsh[:id] = be_a(String) if instance.respond_to?(:id)

          hsh
        end # let

        it 'should define the method' do
          expect(described_class).
            to respond_to(:denormalize).
            with(1).argument.
            and_keywords(:permit)
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
            let(:tools) do
              SleepingKingStudios::Tools::Toolbelt.instance
            end # let

            describe 'with a hash with string keys' do
              let(:normalized) { tools.hash.convert_keys_to_strings(super()) }

              it 'should return an entity' do
                expect(entity).to be_a described_class

                expected.each do |key, match_expected|
                  expect(entity.send key).to match_expected
                end # each
              end # it
            end # describe

            describe 'with a hash with symbol keys' do
              let(:normalized) { tools.hash.convert_keys_to_symbols(super()) }

              it 'should return an entity' do
                expect(entity).to be_a described_class

                expected.each do |key, match_expected|
                  expect(entity.send key).to match_expected
                end # each
              end # it
            end # describe
          end # wrap_context

          context 'when the entity supports dirty tracking' do
            before(:example) do
              mod = Bronze::Entities::Attributes::DirtyTracking

              described_class.send(:include, mod) unless described_class < mod
            end # before example

            it 'should mark the entity as clean' do
              expect(entity.attributes_changed?).to be false
            end # it
          end # context
        end # wrap_context
      end # describe

      describe '#normalize' do
        let(:expected) { instance.attributes }

        it 'should define the method' do
          expect(instance).
            to respond_to(:normalize).
            with(0).arguments.
            and_keywords(:permit)
        end # it

        it { expect(instance.normalize).to be == expected }

        wrap_context 'when the entity class defines many attributes' do
          it { expect(instance.normalize).to be == expected }

          wrap_context 'when the entity has attribute values' do
            let(:expected) { super().merge normalized }

            it { expect(instance.normalize).to be == expected }

            describe 'with :permit => Class' do
              let(:expected) do
                super().merge :happiness => attributes[:happiness]
              end # let

              it 'should normalize the values' do
                result = instance.normalize :permit => BigDecimal

                expect(result).to be == expected
              end # it
            end # describe

            describe 'with :permit => [Class, Class]' do
              let(:expected) do
                super().merge(
                  :happiness   => attributes[:happiness],
                  :captured_at => attributes[:captured_at]
                ) # end expected
              end # let

              it 'should normalize the values' do
                result = instance.normalize :permit => [BigDecimal, DateTime]

                expect(result).to be == expected
              end # it
            end # describe
          end # wrap_context
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
