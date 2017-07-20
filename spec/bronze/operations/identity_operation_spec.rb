# spec/bronze/operations/identity_operation_spec.rb

require 'bronze/operations/identity_operation'

RSpec.describe Bronze::Operations::IdentityOperation do
  let(:instance) { described_class.new }
  let(:value)    { double('value') }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#call' do
    it { expect(instance.call value).to be true }
  end # describe

  describe '#called?' do
    it { expect(instance.called?).to be false }

    it { expect(instance.execute(value).called?).to be true }
  end # describe

  describe '#errors' do
    it { expect(instance.errors).to be == [] }

    it 'should return an empty errors object' do
      errors = instance.execute(value).errors

      expect(errors).to be_a Bronze::Errors
      expect(errors.empty?).to be true
    end # it
  end # describe

  describe '#execute' do
    it { expect { instance.execute(value) }.not_to raise_error }
  end # describe

  describe '#failure?' do
    it { expect(instance.failure?).to be false }

    it { expect(instance.execute(value).failure?).to be false }
  end # describe

  describe '#result' do
    it { expect(instance.result).to be nil }

    it { expect(instance.execute(value).result).to be value }
  end # describe

  describe '#success' do
    it { expect(instance.success?).to be false }

    it { expect(instance.execute(value).success?).to be true }
  end # describe
end # describe
