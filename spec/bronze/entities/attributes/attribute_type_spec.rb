# spec/bronze/entities/attributes/attribute_type_spec.rb

require 'bigdecimal'
require 'date'

require 'bronze/entities/attributes/attribute_type'

RSpec.describe Bronze::Entities::Attributes::AttributeType do
  shared_context 'when the attribute type is an Array' do
    let(:attribute_type) { Array[String] }
  end # shared_context

  shared_context 'when the attribute type is a Hash' do
    let(:attribute_type) { Hash[Symbol, String] }
  end # shared_context

  let(:attribute_type) { Integer }
  let(:instance)       { described_class.new attribute_type }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }

    describe 'should validate the definition' do
      describe 'with nil' do
        it 'should raise an error' do
          expect { described_class.new nil }.
            to raise_error ArgumentError,
              "attribute type can't be blank"
        end # it
      end # it

      describe 'with an object' do
        it 'should raise an error' do
          expect { described_class.new Object.new }.
            to raise_error ArgumentError,
              'attribute type must be a Class'
        end # it
      end # describe

      describe 'with a class' do
        it { expect { described_class.new String }.not_to raise_error }
      end # describe

      describe 'with an empty array' do
        it 'should raise an error' do
          expect { described_class.new [] }.
            to raise_error ArgumentError,
              'specify exactly one Class as member type'
        end # it
      end # describe

      describe 'with an array with an object' do
        it 'should raise an error' do
          expect { described_class.new [Object.new] }.
            to raise_error ArgumentError,
              'attribute type must be a Class'
        end # it
      end # describe

      describe 'with an array with many items' do
        it 'should raise an error' do
          expect { described_class.new [String, Symbol] }.
            to raise_error ArgumentError,
              'specify exactly one Class as member type'
        end # it
      end # describe

      describe 'with an array with a class' do
        it { expect { described_class.new [String] }.not_to raise_error }
      end # describe

      describe 'with an empty hash' do
        it 'should raise an error' do
          expect { described_class.new({}) }.
            to raise_error ArgumentError,
              'specify exactly one key Class and one value Class'
        end # it
      end # describe

      describe 'with a hash with an object value' do
        it 'should raise an error' do
          expect { described_class.new(String => Object.new) }.
            to raise_error ArgumentError,
              'attribute type must be a Class'
        end # it
      end # describe

      describe 'with a hash with many values' do
        it 'should raise an error' do
          expect { described_class.new(Symbol => String, String => Integer) }.
            to raise_error ArgumentError,
              'specify exactly one key Class and one value Class'
        end # it
      end # describe

      describe 'with a hash with non-class key' do
        it 'should raise an error' do
          expect { described_class.new('a String' => Object) }.
            to raise_error ArgumentError,
              'key type must be a Class'
        end # it
      end # describe

      describe 'with a hash with a class value' do
        it 'should not raise an error' do
          expect { described_class.new(String => Integer) }.not_to raise_error
        end # it
      end # describe
    end # describe
  end # describe

  describe '#array?' do
    include_examples 'should have predicate', :array?, false

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.array?).to be true }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it { expect(instance.array?).to be false }
    end # wrap_context
  end # describe

  describe '#collection?' do
    include_examples 'should have predicate', :collection?, false

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.collection?).to be true }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it { expect(instance.collection?).to be true }
    end # wrap_context
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    it 'should return the value' do
      expect(instance.denormalize 0).to be 0
    end # it

    context 'with the attribute type is BigDecimal' do
      let(:attribute_type) { BigDecimal }
      let(:value)          { BigDecimal.new('5.0') }

      it { expect(instance.denormalize value.to_s).to be == value }
    end # context

    context 'with the attribute type is Date' do
      let(:attribute_type) { Date }
      let(:value)          { '1982-07-09' }

      it { expect(instance.denormalize value).to be == Date.new(1982, 7, 9) }
    end # context

    context 'with the attribute type is DateTime' do
      let(:attribute_type) { DateTime }
      let(:value)          { '1982-07-09T12:30:00+0000' }
      let(:expected)       { DateTime.new(1982, 7, 9, 12, 30, 0) }

      it { expect(instance.denormalize value).to be == expected }
    end # context

    context 'with the attribute type is Symbol' do
      let(:attribute_type) { Symbol }
      let(:value)          { 'symbol_value' }

      it { expect(instance.denormalize value.to_s).to be == :symbol_value }
    end # context

    context 'when the attribute type is an Array' do
      let(:attribute_type) { Array[Date] }
      let(:value) do
        [
          '1977-05-25',
          '1980-06-20',
          '1983-05-25'
        ] # end strings
      end # let
      let(:expected) do
        [
          Date.new(1977, 5, 25),
          Date.new(1980, 6, 20),
          Date.new(1983, 5, 25)
        ] # end dates
      end # let

      it { expect(instance.denormalize value).to be == expected }
    end # context

    context 'when the attribute type is a Hash' do
      let(:attribute_type) { Hash[Symbol, Date] }
      let(:value) do
        {
          'anh'  => '1977-05-25',
          'esb'  => '1980-06-20',
          'rotj' => '1983-05-25'
        } # end strings
      end # let
      let(:expected) do
        {
          :anh  => Date.new(1977, 5, 25),
          :esb  => Date.new(1980, 6, 20),
          :rotj => Date.new(1983, 5, 25)
        } # end dates
      end # let

      it { expect(instance.denormalize value).to be == expected }
    end # context
  end # describe

  describe '#hash?' do
    include_examples 'should have predicate', :hash?, false

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.hash?).to be false }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it { expect(instance.hash?).to be true }
    end # wrap_context
  end # describe

  describe '#key_type' do
    include_examples 'should have reader', :key_type, nil

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.key_type).to be nil }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it 'should be an attribute type' do
        attr_type = instance.key_type

        expect(attr_type).to be_a described_class
        expect(attr_type.collection?).to be false
        expect(attr_type.object_type).to be Symbol
      end # it
    end # wrap_context
  end # describe

  describe '#member_type' do
    include_examples 'should have reader', :member_type, nil

    wrap_context 'when the attribute type is an Array' do
      it 'should be an attribute type' do
        attr_type = instance.member_type

        expect(attr_type).to be_a described_class
        expect(attr_type.collection?).to be false
        expect(attr_type.object_type).to be String
      end # it
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it 'should be an attribute type' do
        attr_type = instance.member_type

        expect(attr_type).to be_a described_class
        expect(attr_type.collection?).to be false
        expect(attr_type.object_type).to be String
      end # it
    end # wrap_context
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    it 'should return the value' do
      expect(instance.normalize 0).to be 0
    end # it

    context 'with the attribute type is BigDecimal' do
      let(:attribute_type) { BigDecimal }
      let(:value)          { BigDecimal.new('5.0') }

      it { expect(instance.normalize value).to be == value.to_s }
    end # context

    context 'with the attribute type is Date' do
      let(:attribute_type) { Date }
      let(:value)          { Date.new(1982, 7, 9) }

      it { expect(instance.normalize value).to be == '1982-07-09' }
    end # context

    context 'with the attribute type is DateTime' do
      let(:attribute_type) { DateTime }
      let(:value)          { DateTime.new(1982, 7, 9, 12, 30, 0) }
      let(:expected)       { '1982-07-09T12:30:00+0000' }

      it { expect(instance.normalize value).to be == expected }
    end # context

    context 'with the attribute type is Symbol' do
      let(:attribute_type) { Symbol }
      let(:value)          { :symbol_value }

      it { expect(instance.normalize value).to be == 'symbol_value' }
    end # context

    context 'when the attribute type is an Array' do
      let(:attribute_type) { Array[Date] }
      let(:value) do
        [
          Date.new(1977, 5, 25),
          Date.new(1980, 6, 20),
          Date.new(1983, 5, 25)
        ] # end dates
      end # let
      let(:expected) do
        [
          '1977-05-25',
          '1980-06-20',
          '1983-05-25'
        ] # end strings
      end # let

      it { expect(instance.normalize value).to be == expected }
    end # context

    context 'when the attribute type is a Hash' do
      let(:attribute_type) { Hash[Symbol, Date] }
      let(:value) do
        {
          :anh  => Date.new(1977, 5, 25),
          :esb  => Date.new(1980, 6, 20),
          :rotj => Date.new(1983, 5, 25)
        } # end dates
      end # let
      let(:expected) do
        {
          'anh'  => '1977-05-25',
          'esb'  => '1980-06-20',
          'rotj' => '1983-05-25'
        } # end strings
      end # let

      it { expect(instance.normalize value).to be == expected }
    end # context
  end # describe

  describe '#object_type' do
    include_examples 'should have reader', :object_type, ->() { attribute_type }

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.object_type).to be Array }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it { expect(instance.object_type).to be Hash }
    end # wrap_context
  end # describe
end # describe
