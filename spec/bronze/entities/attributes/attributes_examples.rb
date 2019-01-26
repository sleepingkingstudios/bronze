# spec/bronze/entities/attributes/attributes_examples.rb

require 'bronze/entities/ulid'

module Spec::Entities
  module Attributes; end
end # module

module Spec::Entities::Attributes::AttributesExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_context 'when attributes are defined for the class' do
    let(:described_class) do
      Class.new(super()) do
        attribute :title,            String
        attribute :page_count,       Integer
        attribute :publication_date, Date
      end # class
    end # let
  end # shared_context

  desc = 'should define attribute'
  shared_examples desc do |attr_name, _attr_type, attr_opts = {}|
    reader_name = attr_name
    writer_name = :"#{reader_name}="
    undefined   = Object.new.freeze

    describe "should define attribute :#{attr_name}" do
      let(:entity)         { defined?(super()) ? super() : instance }
      let(:expected_value) { defined?(super()) ? super() : undefined }
      let(:updated_value)  { defined?(super()) ? super() : undefined }

      describe "##{reader_name}" do
        it 'should define the reader' do
          if expected_value == undefined
            expect(entity).to have_reader(reader_name)
          else
            expect(entity).
              to have_reader(reader_name).
              with_value(expected_value)
          end # if-else
        end # it
      end # describe

      describe "##{writer_name}" do
        it 'should define the writer' do
          if attr_opts[:read_only]
            expect(entity).not_to respond_to(writer_name)

            expect(entity).to respond_to(writer_name, true).with(1).argument
          else
            expect(entity).to have_writer(writer_name)
          end # if-else

          unless updated_value == undefined
            expect { entity.send(writer_name, updated_value) }.
              to change(entity, reader_name).
              to be == updated_value
          end # if-else
        end # it
      end # describe
    end # describe

    describe "should not define attribute :#{attr_name} on other entities" do
      let(:entity) { defined?(super()) ? super() : instance }
      let(:other_entity_class) do
        Class.new(Bronze::Entities::BaseEntity) do
          include Bronze::Entities::Attributes
        end # class
      end # let
      let(:other_entity) { other_entity_class.new }

      describe "##{reader_name}" do
        it 'should not define the reader' do
          return if defined?(Bronze::Entities::Entity) &&
                    entity.class == Bronze::Entities::Entity

          expect(other_entity).not_to have_reader(reader_name)
        end # it
      end # describe

      describe "##{writer_name}" do
        it 'should not define the writer' do
          return if defined?(Bronze::Entities::Entity) &&
                    entity.class == Bronze::Entities::Entity

          expect(other_entity).not_to have_writer(writer_name)
        end # it
      end # describe
    end # describe
  end # shared_examples
end # module
