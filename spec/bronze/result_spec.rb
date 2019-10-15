# frozen_string_literal: true

require 'bronze/result'

RSpec.describe Bronze::Result do
  subject(:result) { described_class.new }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0..1).arguments
        .and_keywords(:errors)
    end
  end

  describe '#build_errors' do
    it { expect(result).not_to respond_to(:build_errors) }

    it 'should define the private method' do
      expect(result).to respond_to(:build_errors, true).with(0).arguments
    end

    it { expect(result.send(:build_errors)).to be_a Bronze::Errors }

    it { expect(result.send(:build_errors)).to be_empty }
  end

  describe '#errors' do
    include_examples 'should have property',
      :errors,
      -> { an_instance_of(Bronze::Errors) }

    context 'when initialized with an errors object' do
      let(:errors) do
        Bronze::Errors.new.add('spec.errors.something_went_wrong')
      end
      let(:result) { described_class.new(nil, errors: errors) }

      it { expect(result.errors).to be errors }
    end
  end
end
