# spec/bronze/entities/attributes/dirty_tracking_spec.rb

require 'bronze/entities/associations'
require 'bronze/entities/attributes/dirty_tracking'
require 'bronze/entities/attributes/dirty_tracking_examples'
require 'bronze/entities/base_entity'
require 'bronze/entities/primary_key'

RSpec.describe Bronze::Entities::Attributes::DirtyTracking do
  include Spec::Entities::Attributes::DirtyTrackingExamples

  subject(:instance) { described_class.new(initial_attributes) }

  let(:described_class) do
    klass = Class.new(Bronze::Entities::BaseEntity)
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::Associations
    klass.send :include, Bronze::Entities::PrimaryKey
    klass.send :include, super()
    klass
  end # let
  let(:defined_attributes) { {} }
  let(:initial_attributes) { {} }
  let(:attributes)         { initial_attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Attributes::DirtyTracking methods'
end # describe
