# spec/bronze/entities/entity_spec.rb

require 'bronze/entities/entity'

require 'bronze/entities/attributes/attributes_examples'

RSpec.describe Bronze::Entities::Entity do
  include Spec::Entities::Attributes::AttributesExamples

  shared_context 'when an entity class is defined' do
    let(:described_class) { Class.new(super()) }
  end # context

  let(:described_class)    { Class.new(super()) }
  let(:defined_attributes) { { :id => String } }
  let(:attributes)         { {} }
  let(:instance)           { described_class.new(attributes) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Attributes methods'

  describe '#id' do
    include_examples 'should define attribute',
      :id,
      Bronze::Entities::Ulid,
      :read_only => true

    it 'should generate a ULID' do
      ulid = instance.id

      expect(ulid).to be_a String
      expect(ulid.length).to be == 26

      chars = ulid.split('').uniq
      chars.each do |char|
        expect(Bronze::Entities::Ulid::ENCODING).to include char
      end # each
    end # it

    it 'should be consistent' do
      ids = Array.new(3) { instance.id }.uniq

      expect(ids.length).to be 1
    end # it
  end # describe
end # describe
