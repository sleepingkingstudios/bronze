# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/transforms/attributes/big_decimal_transform'
require 'bronze/transforms/attributes/date_time_transform'
require 'bronze/transforms/attributes/date_transform'
require 'bronze/transforms/attributes/symbol_transform'
require 'bronze/transforms/attributes/time_transform'

require 'support/examples'

module Spec::Support::Examples
  module EntityExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should define attribute' \
    do |attr_name, attr_type, attr_opts = {}|
      describe '::attributes' do
        describe "with :#{attr_name}" do
          let(:metadata) { described_class.attributes[attr_name.intern] }
          let(:expected_transform) do
            attr_opts.fetch(:transform) { expected_transform_for(attr_type) }
          end

          # rubocop:disable Metrics/MethodLength
          def expected_transform_for(type)
            case type.name
            when 'BigDecimal'
              Bronze::Transforms::Attributes::BigDecimalTransform
            when 'Date'
              Bronze::Transforms::Attributes::DateTransform
            when 'DateTime'
              Bronze::Transforms::Attributes::DateTimeTransform
            when 'Symbol'
              Bronze::Transforms::Attributes::SymbolTransform
            when 'Time'
              Bronze::Transforms::Attributes::TimeTransform
            end
          end
          # rubocop:enable Metrics/MethodLength

          def match_expected_default(default)
            default = default.is_a?(Proc) ? instance_exec(&default) : default

            return default if default.respond_to?(:matches?)

            match default
          end

          it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

          it { expect(metadata.name).to be attr_name.intern }

          it { expect(metadata.type).to be attr_type }

          it { expect(metadata.allow_nil?).to be !!attr_opts[:allow_nil] }

          it { expect(metadata.default?).to be !!attr_opts[:default] }

          it 'should set the default value' do
            expect(metadata.default)
              .to match_expected_default(attr_opts[:default])
          end

          it 'should set the default transform flag' do
            expect(metadata.default_transform?).to be !attr_opts[:transform]
          end

          it { expect(metadata.foreign_key?).to be !!attr_opts[:foreign_key] }

          it { expect(metadata.primary_key?).to be !!attr_opts[:primary_key] }

          it { expect(metadata.read_only?).to be !!attr_opts[:read_only] }

          it { expect(metadata.transform).to be_a expected_transform }

          it { expect(metadata.transform?).to be !expected_transform.nil? }
        end
      end

      describe '#attribute?' do
        it { expect(subject.attribute? attr_name).to be true }
      end

      describe attr_name.to_s do
        def match_expected_attribute(attr_name)
          value = expected_attributes[attr_name.intern]

          return value if value.respond_to?(:matches?)

          match value
        end

        include_examples 'should have reader',
          attr_name,
          -> { match_expected_attribute(attr_name) }
      end

      describe "#{attr_name}=" do
        if attr_opts[:read_only]
          include_examples 'should have private writer', :"#{attr_name}="
        else
          include_examples 'should have writer', :"#{attr_name}="
        end
      end
    end

    shared_examples 'should define primary key' \
    do |attr_name, attr_type, attr_opts = {}|
      options = {
        primary_key: true,
        read_only:   true
      }.merge(attr_opts)

      include_examples 'should define attribute', attr_name, attr_type, options
    end

    shared_examples 'should define UUID primary key' do |attr_name|
      options = {
        default:     -> { be_a_uuid },
        primary_key: true,
        read_only:   true
      }

      include_examples 'should define attribute', attr_name, String, options
    end
  end
end
