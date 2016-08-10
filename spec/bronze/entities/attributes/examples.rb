# spec/bronze/entities/attributes/examples.rb

module Spec::Entities
  module Attributes; end
end # module

module Spec::Entities::Attributes::AttributesExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_examples 'should define attribute' do |attribute_name|
    reader_name = attribute_name
    writer_name = :"#{reader_name}="
    undefined   = Object.new.freeze

    describe "should define attribute :#{attribute_name}" do
      let(:entity)         { defined?(super()) ? super() : instance }
      let(:expected_value) { defined?(super()) ? super() : undefined }
      let(:updated_value)  { defined?(super()) ? super() : undefined }

      describe "##{reader_name}" do
        it 'should define the reader' do
          if expected_value == undefined
            expect(entity).to have_reader(attribute_name)
          else
            expect(entity).
              to have_reader(attribute_name).
              with_value(attributes.fetch attribute_name)
          end # if-else
        end # it
      end # describe

      describe "##{writer_name}" do
        it 'should define the writer' do
          expect(entity).to have_writer(writer_name)

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
