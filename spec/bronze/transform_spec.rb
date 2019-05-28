# frozen_string_literal: true

require 'bronze/transform'

RSpec.describe Bronze::Transform do
  subject(:transform) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#<<' do
    let(:other_transform)    { described_class.new }
    let(:composed_transform) { transform << other_transform }

    it { expect(transform).to respond_to(:<<).with(1).argument }

    it 'should return a composed transform' do
      expect(transform << other_transform)
        .to be_a Bronze::Transforms::ComposedTransform
    end

    it 'should set the left transform' do
      expect(composed_transform.send(:left_transform)).to be other_transform
    end

    it 'should set the right transform' do
      expect(composed_transform.send(:right_transform)).to be transform
    end
  end

  describe '#>>' do
    let(:other_transform)    { described_class.new }
    let(:composed_transform) { transform >> other_transform }

    it { expect(transform).to respond_to(:>>).with(1).argument }

    it 'should return a composed transform' do
      expect(transform >> other_transform)
        .to be_a Bronze::Transforms::ComposedTransform
    end

    it 'should set the left transform' do
      expect(composed_transform.send(:left_transform)).to be transform
    end

    it 'should set the right transform' do
      expect(composed_transform.send(:right_transform)).to be other_transform
    end
  end

  describe '#denormalize' do
    let(:error_message) do
      "#{described_class.name}#denormalize is not implemented"
    end

    it { expect(transform).to respond_to(:denormalize).with(1).argument }

    it 'should raise an error' do
      expect { transform.denormalize Object.new }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#normalize' do
    let(:error_message) do
      "#{described_class.name}#normalize is not implemented"
    end

    it { expect(transform).to respond_to(:normalize).with(1).argument }

    it 'should raise an error' do
      expect { transform.normalize Object.new }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end
end
