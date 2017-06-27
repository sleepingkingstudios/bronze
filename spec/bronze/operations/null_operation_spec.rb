# spec/bronze/operations/null_operation_spec.rb

require 'bronze/operations/null_operation'

RSpec.describe Bronze::Operations::NullOperation do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#call' do
    it { expect(instance.call).to be true }
  end # describe

  describe '#called?' do
    it { expect(instance.called?).to be false }

    it { expect(instance.execute.called?).to be true }
  end # describe

  describe '#errors' do
    it { expect(instance.errors).to be == [] }

    it 'should return an empty errors object' do
      errors = instance.execute.errors

      expect(errors).to be_a Bronze::Errors
      expect(errors.empty?).to be true
    end # it
  end # describe

  describe '#execute' do
    it { expect { instance.execute }.not_to raise_error }
  end # describe

  describe '#failure?' do
    it { expect(instance.failure?).to be false }

    it { expect(instance.execute.failure?).to be false }
  end # describe

  describe '#halt!' do
    it { expect(instance.halt!).to be instance }

    it { expect { instance.halt! }.to change(instance, :halted?).to be true }
  end # describe

  describe '#halted?' do
    it { expect(instance.halted?).to be false }
  end # describe

  describe '#result' do
    it { expect(instance.result).to be nil }

    it { expect(instance.execute.result).to be nil }
  end # describe

  describe '#success' do
    it { expect(instance.success?).to be false }

    it { expect(instance.execute.success?).to be true }
  end # describe
end # describe
