# frozen_string_literal: true

require 'bronze/transforms/composed_transform'

require 'support/transforms/stringify_transform'
require 'support/transforms/symbolize_transform'
require 'support/transforms/underscore_transform'
require 'support/transforms/upcase_transform'

RSpec.describe Bronze::Transforms::ComposedTransform do
  subject(:transform) { described_class.new(left_transform, right_transform) }

  let(:left_transform)  { Spec::UnderscoreTransform.new }
  let(:right_transform) { Spec::UpcaseTransform.new }

  describe '#new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end

  describe '#<<' do
    let(:other_transform)    { Spec::StringifyTransform.new }
    let(:composed_transform) { transform << other_transform }

    it { expect(transform).to respond_to(:<<).with(1).argument }

    it { expect(transform << other_transform).to be_a described_class }

    it 'should set the left transform' do
      expect(composed_transform.send(:left_transform)).to be other_transform
    end

    it 'should set the right transform' do
      expect(composed_transform.send(:right_transform)).to be transform
    end

    describe 'when #denormalize is called' do
      let(:input)  { 'GREETINGS_PROGRAMS' }
      let(:output) { :GreetingsPrograms }

      it 'should chain the transforms' do
        expect(composed_transform.denormalize(input)).to be == output
      end
    end

    describe 'when #normalize is called' do
      let(:input)  { :GreetingsPrograms }
      let(:output) { 'GREETINGS_PROGRAMS' }

      it 'should chain the transforms' do
        expect(composed_transform.normalize(input)).to be == output
      end
    end
  end

  describe '#>>' do
    let(:other_transform)    { Spec::SymbolizeTransform.new }
    let(:composed_transform) { transform >> other_transform }

    it { expect(transform).to respond_to(:>>).with(1).argument }

    it { expect(transform >> other_transform).to be_a described_class }

    it 'should set the left transform' do
      expect(composed_transform.send(:left_transform)).to be transform
    end

    it 'should set the right transform' do
      expect(composed_transform.send(:right_transform)).to be other_transform
    end

    describe 'when #denormalize is called' do
      let(:input)  { :GREETINGS_PROGRAMS }
      let(:output) { 'GreetingsPrograms' }

      it 'should chain the transforms' do
        expect(composed_transform.denormalize(input)).to be == output
      end
    end

    describe 'when #normalize is called' do
      let(:input)  { 'GreetingsPrograms' }
      let(:output) { :GREETINGS_PROGRAMS }

      it 'should chain the transforms' do
        expect(composed_transform.normalize(input)).to be == output
      end
    end
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

  describe '#left_transform' do
    include_examples 'should have private reader',
      :left_transform,
      -> { left_transform }
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

  describe '#right_transform' do
    include_examples 'should have private reader',
      :right_transform,
      -> { right_transform }
  end
end
