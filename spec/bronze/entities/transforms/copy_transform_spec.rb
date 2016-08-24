# spec/bronze/entities/transforms/copy_transform_spec.rb

require 'bronze/entities/transforms/copy_transform'

RSpec.describe Bronze::Entities::Transforms::CopyTransform do
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
      let(:copy)   { Object.new }

      before(:example) do
        allow(object).to receive(:dup).and_return(copy)
      end # before

      it 'should return a copy of the object' do
        expect(instance.denormalize object).to be copy
      end # it
    end # describe

    describe 'with an attributes hash' do
      let(:attributes) { { :id => '0', :title => 'The Last Ringbearer' } }

      it 'should return a deep copy of the attributes' do
        copy = instance.denormalize attributes

        expect(copy).to be == attributes

        expect { copy[:id] = '1' }.not_to change { attributes }
        expect { copy[:title][0..-1] = 'Bored of the Rings' }.
          not_to change { attributes }
      end # it
    end # describe
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be nil }
    end # describe

    describe 'with an Object' do
      let(:object) { Object.new }
      let(:copy)   { Object.new }

      before(:example) do
        allow(object).to receive(:dup).and_return(copy)
      end # before

      it 'should return a copy of the object' do
        expect(instance.normalize object).to be copy
      end # it
    end # describe

    describe 'with an attributes hash' do
      let(:attributes) { { :id => '0', :title => 'The Last Ringbearer' } }

      it 'should return a deep copy of the attributes' do
        copy = instance.normalize attributes

        expect(copy).to be == attributes

        expect { copy[:id] = '1' }.not_to change { attributes }
        expect { copy[:title][0..-1] = 'Bored of the Rings' }.
          not_to change { attributes }
      end # it
    end # describe
  end # describe
end # describe
