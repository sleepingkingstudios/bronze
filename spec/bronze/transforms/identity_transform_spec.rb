# frozen_string_literal: true

require 'bronze/transforms/identity_transform'

RSpec.describe Bronze::Transforms::IdentityTransform do
  subject(:transform) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '::instance' do
    it { expect(described_class).to have_reader(:instance) }

    it { expect(described_class.instance).to be_a described_class }

    it 'should return a memoized instance' do
      transform = described_class.instance

      3.times { expect(described_class.instance).to be transform }
    end
  end

  describe '#denormalize' do
    it { expect(transform).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.denormalize nil).to be nil }
    end

    describe 'with an Object' do
      let(:object) { Object.new }

      it { expect(transform.denormalize object).to be == object }
    end

    describe 'with an attributes hash' do
      let(:attributes) { { id: '0', title: 'The Last Ringbearer' } }

      it { expect(transform.denormalize attributes).to be == attributes }
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with an Object' do
      let(:object) { Object.new }

      it { expect(transform.normalize object).to be == object }
    end

    describe 'with an attributes hash' do
      let(:attributes) { { id: '0', title: 'The Last Ringbearer' } }

      it { expect(transform.normalize attributes).to be == attributes }
    end
  end
end
