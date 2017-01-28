# spec/bronze/transforms/transform_chain_spec.rb

require 'bronze/transforms/transform_chain'

RSpec.describe Bronze::Transforms::TransformChain do
  shared_context 'when the sequence has many transforms' do
    def build_transform name, denormalize, normalize
      double(name).tap do |transform|
        allow(transform).to receive(:denormalize, &denormalize)
        allow(transform).to receive(:normalize,   &normalize)
      end # tap
    end # method build_transform

    let(:transforms) do
      string_tools = SleepingKingStudios::Tools::StringTools

      [
        build_transform(
          'underscore transform',
          ->(s) { string_tools.camelize(s) },
          ->(s) { string_tools.underscore(s) }
        ),
        build_transform(
          'pluralize transform',
          ->(s) { string_tools.singularize(s) },
          ->(s) { string_tools.pluralize(s) }
        ),
        build_transform(
          'underscore transform',
          ->(s) { s.to_s },
          ->(s) { s.intern }
        )
      ] # end transforms
    end # let
  end # shared_context

  let(:transforms) { [] }
  let(:instance)   { described_class.new(*transforms) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with_unlimited_arguments }
  end # describe

  describe '#chain' do
    let(:transform) { double('capitalize transform') }

    it { expect(instance).to respond_to(:chain).with(1).argument }

    it 'should append the transform to the sequence' do
      expect { instance.chain transform }.
        to change(instance, :transforms).
        to be == [transform]
    end # it

    wrap_context 'when the sequence has many transforms' do
      it 'should append the transform to the sequence' do
        expect { instance.chain transform }.
          to change(instance, :transforms).
          to be == [*transforms, transform]
      end # it
    end # wrap_context
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    it 'should return the object' do
      expect(instance.denormalize 'Book').to be == 'Book'
    end # it

    wrap_context 'when the sequence has many transforms' do
      it 'should call each transform' do
        expect(instance.denormalize :books).to be == 'Book'
      end # it
    end # wrap_c
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    it 'should return the object' do
      expect(instance.normalize 'Book').to be == 'Book'
    end # it

    wrap_context 'when the sequence has many transforms' do
      it 'should call each transform' do
        expect(instance.normalize 'Book').to be == :books
      end # it
    end # wrap_context
  end # describe

  describe '#transforms' do
    include_examples 'should have reader',
      :transforms,
      ->() { be == transforms }

    wrap_context 'when the sequence has many transforms' do
      it { expect(instance.transforms).to be == transforms }
    end # wrap_context
  end # describe
end # describe
