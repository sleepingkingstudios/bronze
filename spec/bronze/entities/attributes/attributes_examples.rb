# spec/bronze/entities/attributes/attributes_examples.rb

module Spec::Entities
  module Attributes; end
end # module

module Spec::Entities::Attributes::AttributesExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  # rubocop:disable Metrics/LineLength
  shared_examples 'should define attribute' do |attr_name, _attr_type, attr_opts = {}|
    # rubocop:enable Metrics/LineLength
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
            expect(entity).to have_reader(attr_name)
          else
            expect(entity).
              to have_reader(attr_name).
              with_value(attributes.fetch attr_name)
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
  end # shared_examples
end # module
