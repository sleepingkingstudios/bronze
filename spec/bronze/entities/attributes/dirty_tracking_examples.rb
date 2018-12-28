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
          expect(entity).
            to have_predicate(:"#{reader_name}_changed?").
            with_value false
        end # it
      end # describe

      describe "##{reader_name}_changed_from" do
        it 'should define the predicate' do
          expect(entity).
            to have_reader(:"#{reader_name}_changed_from").
            with_value nil
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

          it 'should not change the cached prior attribute value' do
            expect { entity.send(writer_name, prior_value) }.
              not_to change(entity, :"#{reader_name}_changed_from")
          end # it
        end # describe

        describe 'with a new value' do
          it 'should mark the entity as changed' do
            entity.send(writer_name, updated_value)

            expect(entity.attributes_changed?).to be true
          end # it

          it 'should mark the attribute as changed' do
            entity.send(writer_name, updated_value)

            expect(entity.send(:"#{reader_name}_changed?")).to be true
          end # it

          it 'should set the cached prior attribute value' do
            expect { entity.send(writer_name, updated_value) }.
              to change(entity, :"#{reader_name}_changed_from").
              to be == prior_value
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

    describe '::foreign_key' do
      describe 'with a valid attribute name' do
        let(:attribute_name) { :association_id }
        let(:attribute_type) { described_class::KEY_TYPE }
        let(:attributes) do
          super().merge :association_id => Bronze::Entities::Ulid.generate
        end # let

        context 'when the attribute has been defined' do
          before(:example) { described_class.foreign_key(attribute_name) }

          include_examples 'should track changes to attribute', :association_id
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

    describe '#clean_attributes' do
      it { expect(instance).to respond_to(:clean_attributes).with(0).arguments }

      it 'should mark the entity as unchanged' do
        instance.clean_attributes

        expect(instance.attributes_changed?).to be false

        instance.class.attributes.each do |_, metadata|
          next if metadata.name == :id

          attr_changed_name      = :"#{metadata.reader_name}_changed?"
          attr_changed_from_name = :"#{metadata.reader_name}_changed_from"

          expect(instance.send attr_changed_name).to be false
          expect(instance.send attr_changed_from_name).to be nil
        end # each
      end # it

      context 'when the attribute values have been changed' do
        before(:example) do
          described_class.attribute :title, String

          instance.title = 'The Tale of Genji'
        end # before example

        it 'should mark the entity as unchanged' do
          instance.clean_attributes

          expect(instance.attributes_changed?).to be false

          instance.class.attributes.each do |_, metadata|
            next if metadata.name == :id

            attr_changed_name      = :"#{metadata.reader_name}_changed?"
            attr_changed_from_name = :"#{metadata.reader_name}_changed_from"

            expect(instance.send attr_changed_name).to be false
            expect(instance.send attr_changed_from_name).to be nil
          end # each
        end # it
      end # context
    end # describe
  end # shared_examples
end # module
