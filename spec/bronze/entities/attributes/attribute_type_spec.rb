# spec/bronze/entities/attributes/attribute_type_spec.rb

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

  describe '#collection?' do
    include_examples 'should have predicate', :collection?, false

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.collection?).to be true }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it { expect(instance.collection?).to be true }
    end # wrap_context
  end # describe

  describe '#key_type' do
    include_examples 'should have reader', :key_type, nil

    wrap_context 'when the attribute type is an Array' do
      it { expect(instance.key_type).to be nil }
    end # wrap_context

    wrap_context 'when the attribute type is a Hash' do
      it { expect(instance.key_type).to be Symbol }
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
