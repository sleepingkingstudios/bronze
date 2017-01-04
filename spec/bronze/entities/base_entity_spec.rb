# spec/bronze/entities/base_entity_spec.rb

require 'bronze/entities/base_entity'

RSpec.describe Bronze::Entities::BaseEntity do
  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe
end # describe
