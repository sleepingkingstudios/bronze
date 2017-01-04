# spec/bronze/entities/associations_spec.rb

require 'bronze/entities/associations'
require 'bronze/entities/base_entity'

RSpec.describe Bronze::Entities::Associations do
  let(:described_class) do
    klass = Class.new(Bronze::Entities::BaseEntity)
    klass.send :include, super()
    klass
  end # let
  let(:attributes) { {} }
  let(:instance)   { described_class.new attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe
end # describe
