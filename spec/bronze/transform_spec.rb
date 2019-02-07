# frozen_string_literal: true

require 'bronze/transform'

RSpec.describe Bronze::Transform do
  subject(:transform) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
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
