# spec/bronze/entities/attributes/dirty_tracking/dirty_tracking_builder_spec.rb

require 'bronze/entities/base_entity'
require 'bronze/entities/attributes/dirty_tracking_examples'
require 'bronze/entities/attributes/dirty_tracking/dirty_tracking_builder'

# rubocop:disable Metrics/LineLength
RSpec.describe Bronze::Entities::Attributes::DirtyTracking::DirtyTrackingBuilder do
  # rubocop:enable Metrics/LineLength
  include Spec::Entities::Attributes::DirtyTrackingExamples

  let(:entity_class) do
    Class.new(Bronze::Entities::BaseEntity) do
      include Bronze::Entities::Attributes

      attribute :title, String

      include Bronze::Entities::Attributes::DirtyTracking
    end # class
  end # let
  let(:entity)   { entity_class.new :title => 'The Epic of Gilgamesh' }
  let(:instance) { described_class.new(entity_class) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#build' do
    it { expect(instance).to respond_to(:build).with(1).argument }

    describe 'with a valid attribute metadata' do
      let(:metadata) { entity_class.attributes[:title] }

      context 'when the attribute tracking has been set up' do
        before(:example) { instance.build(metadata) }

        include_examples 'should track changes to attribute', :title
      end # context
    end # describe
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe
end # describe
