# spec/patina/collections/mongo/primary_key_transform_spec.rb

require 'patina/collections/mongo/primary_key_transform'

RSpec.describe Patina::Collections::Mongo::PrimaryKeyTransform do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#denormalize' do
    let(:hsh)      { { '_id' => '0', 'title' => 'The Book of Lost Tales' } }
    let(:expected) { { 'id' => '0', 'title' => 'The Book of Lost Tales' } }

    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    it 'should rename the primary key' do
      expect(instance.denormalize hsh).to be == expected
    end # it
  end # describe

  describe '#normalize' do
    let(:hsh)      { { 'id' => '0', 'title' => 'The Book of Lost Tales' } }
    let(:expected) { { '_id' => '0', 'title' => 'The Book of Lost Tales' } }

    it { expect(instance).to respond_to(:normalize).with(1).argument }

    it 'should rename the primary key' do
      expect(instance.normalize hsh).to be == expected
    end # it

    describe 'with symbolic keys' do
      let(:hash_tools) { SleepingKingStudios::Tools::HashTools }
      let(:hsh)        { hash_tools.convert_keys_to_symbols(super()) }
      let(:expected)   { hash_tools.convert_keys_to_symbols(super()) }

      it 'should rename the primary key' do
        expect(instance.normalize hsh).to be == expected
      end # it
    end # describe
  end # describe
end # describe
