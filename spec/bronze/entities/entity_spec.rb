# spec/bronze/entities/entity_spec.rb

require 'bronze/entities/entity'

RSpec.describe Bronze::Entities::Entity do
  shared_context 'when an entity subclass is defined' do
    let(:described_class) { Class.new(super()) }
  end # context

  shared_examples 'should define attribute' do |attribute_name|
    reader_name = attribute_name
    writer_name = :"#{reader_name}="
    undefined   = Object.new.freeze

    let(:expected_value) { defined?(super()) ? super() : undefined }
    let(:updated_value)  { defined?(super()) ? super() : undefined }

    describe "##{reader_name}" do
      it 'should define the reader' do
        if expected_value == undefined
          expect(instance).to have_reader(attribute_name)
        else
          expect(instance).
            to have_reader(attribute_name).
            with_value(attributes.fetch attribute_name)
        end # if-else
      end # it
    end # describe

    describe "##{writer_name}" do
      it 'should define the writer' do
        expect(instance).to have_writer(writer_name)

        unless updated_value == undefined
          expect { instance.send(writer_name, updated_value) }.
            to change(instance, reader_name).
            to be == updated_value
        end # if-else
      end # it
    end # describe
  end # shared_examples

  let(:attributes) { {} }
  let(:instance)   { described_class.new(attributes) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '::attribute' do
    it 'should respond to the method' do
      expect(described_class).to respond_to(:attribute).with(2..3).arguments
    end # it

    wrap_context 'when an entity subclass is defined' do
      describe 'with a valid attribute name and attribute type' do
        let(:attribute_name) { :title }
        let(:attribute_type) { String }
        let(:attributes)     { super().merge :title => 'The Ramayana' }
        let(:expected_value) { attributes.fetch attribute_name }

        before(:example) do
          described_class.attribute attribute_name, attribute_type
        end # before example

        include_examples 'should define attribute', :title
      end # describe
    end # wrap_context
  end # describe
end # describe
