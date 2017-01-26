# spec/bronze/transforms/attributes_transform_spec.rb

require 'bronze/transforms/attributes_transform'

RSpec.describe Bronze::Transforms::AttributesTransform do
  shared_context 'when a transform class is defined' do
    let(:described_class) { Class.new(super()) }
  end # context

  shared_context 'when a transform class is defined with many attributes' do
    let(:described_class) do
      Class.new(super()) do
        attributes :title, :author, :preface
      end # class
    end # let
  end # context

  let(:object_class) do
    Struct.new(:id, :title, :author, :preface)
  end # let
  let(:instance) { described_class.new object_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::attribute' do
    it { expect(described_class).to respond_to(:attribute).with(1).argument }

    describe 'with an attribute name' do
      include_context 'when a transform class is defined'

      let(:attribute_name) { :isbn }

      it 'should add the attribute name to the set' do
        expect { described_class.attribute attribute_name }.
          to change { described_class.attribute_names.count }.by(1)

        expect(described_class.attribute_names).to include attribute_name
      end # it
    end # describe
  end # it

  describe '::attributes' do
    it 'should define the method' do
      expect(described_class).to respond_to(:attributes).
        with_unlimited_arguments
    end # it

    describe 'with many attribute names' do
      include_context 'when a transform class is defined'

      let(:attribute_names) { [:isbn, :page_count, :published_at] }

      it 'should add the attribute names to the set' do
        expect { described_class.attributes(*attribute_names) }.
          to change { described_class.attribute_names.count }.
          by(attribute_names.count)

        expect(described_class.attribute_names).to include(*attribute_names)
      end # it
    end # describe
  end # describe

  describe '::attribute_names' do
    it 'should define the reader' do
      expect(described_class).to have_reader(:attribute_names).
        with_value(an_instance_of Set)
    end # it

    it 'should return the set containing :id' do
      expect(described_class.attribute_names).to contain_exactly :id
    end # it

    wrap_context 'when a transform class is defined with many attributes' do
      it 'should return the set containing the attribute names' do
        expect(described_class.attribute_names).
          to contain_exactly :id, :title, :author, :preface
      end # it
    end # wrap_context
  end # describe

  describe '#attribute_names' do
    include_examples 'should have reader',
      :attribute_names,
      ->() { an_instance_of Set }

    it 'should return the set containing :id' do
      expect(instance.attribute_names).to contain_exactly :id
    end # it

    wrap_context 'when a transform class is defined with many attributes' do
      it 'should return the set containing :id and the attribute names' do
        expect(instance.attribute_names).
          to contain_exactly :id, :title, :author, :preface
      end # it
    end # wrap_context
  end # describe

  describe '#denormalize' do
    let(:attribute_names) { [:id] }
    let(:expected) do
      attribute_names.each.with_object(object_class.new) do |attr_name, entity|
        attr_value = attributes[attr_name] || attributes[attr_name.to_s]

        entity.send(:"#{attr_name}=", attr_value)
      end # each
    end # let

    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.denormalize nil).to be == object_class.new }
    end # describe

    describe 'with an empty attributes hash' do
      it { expect(instance.denormalize({})).to be == object_class.new }
    end # describe

    describe 'with an attributes hash with string keys' do
      let(:attributes) do
        { 'id' => '0', 'title' => 'The Art of War', 'author' => 'Sun Tzu' }
      end # let

      it { expect(instance.denormalize attributes).to be == expected }
    end # describe

    describe 'with an attributes hash with symbol keys' do
      let(:attributes) do
        { :id => '0', :title => 'The Art of War', :author => 'Sun Tzu' }
      end # let

      it { expect(instance.denormalize attributes).to be == expected }
    end # describe

    wrap_context 'when a transform class is defined with many attributes' do
      let(:attribute_names) { [:id, :title, :author, :preface] }

      describe 'with an empty attributes hash' do
        it { expect(instance.denormalize({})).to be == object_class.new }
      end # describe

      describe 'with an attributes hash with string keys' do
        let(:attributes) do
          { 'id' => '0', 'title' => 'The Art of War', 'author' => 'Sun Tzu' }
        end # let

        it { expect(instance.denormalize attributes).to be == expected }
      end # describe

      describe 'with an attributes hash with symbol keys' do
        let(:attributes) do
          { :id => '0', :title => 'The Art of War', :author => 'Sun Tzu' }
        end # let

        it { expect(instance.denormalize attributes).to be == expected }
      end # describe
    end # wrap_context
  end # describe

  describe '#object_class' do
    include_examples 'should have reader', :object_class, ->() { object_class }
  end # describe

  describe '#normalize' do
    let(:attribute_names) { [:id] }
    let(:expected) do
      attribute_names.each.with_object({}) do |attr_name, hsh|
        hsh[attr_name] = entity.send(attr_name)
      end # each
    end # let

    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be == {} }
    end # describe

    describe 'with an entity with empty attributes' do
      let(:entity) { object_class.new }

      it { expect(instance.normalize entity).to be == expected }
    end # describe

    describe 'with an entity with set attributes' do
      let(:entity) { object_class.new '0', 'The Art of War', 'Sun Tzu' }

      it { expect(instance.normalize entity).to be == expected }
    end # describe

    wrap_context 'when a transform class is defined with many attributes' do
      let(:attribute_names) { [:id, :title, :author, :preface] }

      describe 'with an entity with empty attributes' do
        let(:entity) { object_class.new }

        it { expect(instance.normalize entity).to be == expected }
      end # describe

      describe 'with an entity with set attributes' do
        let(:entity) { object_class.new '0', 'The Art of War', 'Sun Tzu' }

        it { expect(instance.normalize entity).to be == expected }
      end # describe
    end # wrap_context
  end # describe
end # describe
