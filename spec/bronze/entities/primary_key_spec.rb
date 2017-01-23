# spec/bronze/entities/primary_key_spec.rb

require 'bronze/entities/attributes'
require 'bronze/entities/base_entity'
require 'bronze/entities/primary_key'
require 'bronze/entities/primary_key_examples'

RSpec.describe Bronze::Entities::PrimaryKey do
  include Spec::Entities::PrimaryKeyExamples

  let(:described_class) do
    Class.new(Bronze::Entities::BaseEntity) do
      include Bronze::Entities::Attributes
      include Bronze::Entities::PrimaryKey
    end # class
  end # let
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the PrimaryKey methods'
end # describe
