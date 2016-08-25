# spec/bronze/transforms/identity_transform_spec.rb

require 'bronze/transforms/identity_transform'

RSpec.describe Bronze::Transforms::IdentityTransform do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).argument }
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.denormalize nil).to be nil }
    end # describe

    describe 'with an Object' do
      let(:object) { Object.new }

      it { expect(instance.denormalize object).to be == object }
    end # describe

    describe 'with an attributes hash' do
      let(:attributes) { { :id => '0', :title => 'The Last Ringbearer' } }

      it { expect(instance.denormalize attributes).to be == attributes }
    end # describe
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be nil }
    end # describe

    describe 'with an Object' do
      let(:object) { Object.new }

      it { expect(instance.normalize object).to be == object }
    end # describe

    describe 'with an attributes hash' do
      let(:attributes) { { :id => '0', :title => 'The Last Ringbearer' } }

      it { expect(instance.normalize attributes).to be == attributes }
    end # describe
  end # describe
end # describe
