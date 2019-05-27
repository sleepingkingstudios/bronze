# frozen_string_literal: true

require 'bronze/transforms/composed_transform'

require 'support/transforms/underscore_transform'
require 'support/transforms/upcase_transform'

RSpec.describe Bronze::Transforms::ComposedTransform do
  subject(:transform) { described_class.new(left_transform, right_transform) }

  let(:left_transform)  { Spec::UnderscoreTransform.new }
  let(:right_transform) { Spec::UpcaseTransform.new }

  describe '#new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end

  describe '#denormalize' do
    let(:input)        { 'GREETINGS_PROGRAMS' }
    let(:intermediate) { 'greetings_programs' }
    let(:output)       { 'GreetingsPrograms' }

    it 'should call right transform with the input value' do
      allow(right_transform).to receive(:denormalize).and_call_original

      transform.denormalize(input)

      expect(right_transform).to have_received(:denormalize).with(input)
    end

    it 'should call left transform with the intermediate result' do
      allow(left_transform).to receive(:denormalize)

      transform.denormalize(input)

      expect(left_transform).to have_received(:denormalize).with(intermediate)
    end

    it 'should return the output value' do
      expect(transform.denormalize(input)).to be == output
    end
  end

  describe '#normalize' do
    let(:input)        { 'GreetingsPrograms' }
    let(:intermediate) { 'greetings_programs' }
    let(:output)       { 'GREETINGS_PROGRAMS' }

    it 'should call left transform with the input value' do
      allow(left_transform).to receive(:normalize).and_call_original

      transform.normalize(input)

      expect(left_transform).to have_received(:normalize).with(input)
    end

    it 'should call right transform with the intermediate result' do
      allow(right_transform).to receive(:normalize)

      transform.normalize(input)

      expect(right_transform).to have_received(:normalize).with(intermediate)
    end

    it 'should return the output value' do
      expect(transform.normalize(input)).to be == output
    end
  end
end
