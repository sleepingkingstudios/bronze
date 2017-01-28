# spec/bronze/entities/attributes/dirty_tracking_examples.rb

require 'bronze/entities/attributes/attributes_examples'

module Spec::Entities
  module Attributes; end
end # module

module Spec::Entities::Attributes::DirtyTrackingExamples
  extend  RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
  include Spec::Entities::Attributes::AttributesExamples

  shared_examples 'should track changes to attribute' do |attr_name|
    reader_name = attr_name
    writer_name = :"#{reader_name}="
    undefined   = Object.new.freeze

    describe "should track changes to attribute :#{attr_name}" do
      let(:entity) { defined?(super()) ? super() : instance }
      let(:prior_value) do
        defined?(super()) ? super() : entity.send(reader_name)
      end # let
      let(:updated_value) { defined?(super()) ? super() : undefined }

      describe "##{reader_name}_changed?" do
        it 'should define the predicate' do
          expect(instance).
            to have_predicate(:"#{reader_name}_changed?").
            with_value false
        end # it
      end # describe

      describe "##{writer_name}" do
        describe 'with the existing value' do
          it 'should not mark the entity as changed' do
            expect { entity.send(writer_name, prior_value) }.
              not_to change(entity, :attributes_changed?)
          end # it

          it 'should not mark the attribute as changed' do
            expect { entity.send(writer_name, prior_value) }.
              not_to change(entity, :"#{reader_name}_changed?")
          end # it
        end # describe

        describe 'with a new value' do
          it 'should mark the entity as changed' do
            entity.send(writer_name, updated_value)

            expect(entity.attributes_changed?).to be true
          end # it

          it 'should not mark the attribute as changed' do
            entity.send(writer_name, updated_value)

            expect(entity.send(:"#{reader_name}_changed?")).to be true
          end # it
        end # describe
      end # describe
    end # describe
  end # shared_examples

  shared_examples 'should implement the Attributes::DirtyTracking methods' do
    describe '::attribute' do
      shared_context 'when the attribute has been defined' do
        let!(:metadata) do
          described_class.attribute(
            attribute_name,
            attribute_type,
            attribute_opts
          ) # end attribute
        end # let!
      end # shared_context

      describe 'with a valid attribute name and attribute type' do
        let(:attribute_name) { :title }
        let(:attribute_type) { String }
        let(:attribute_opts) { {} }
        let(:attributes)     { super().merge :title => 'The Ramayana' }

        wrap_context 'when the attribute has been defined' do
          include_examples 'should track changes to attribute', :title
        end # wrap_context
      end # describe
    end # describe

    describe '#attributes_changed?' do
      it 'should define the predicate' do
        expect(instance).
          to have_predicate(:attributes_changed?).
          with_value(false)
      end # it
    end # describe
  end # shared_examples
end # module
