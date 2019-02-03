# frozen_string_literal: true

require 'support/entities/book'
require 'support/examples/entity_examples'

RSpec.describe Spec::Book do
  include Spec::Support::Examples::EntityExamples

  subject(:book) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      id:               nil,
      title:            nil,
      isbn:             nil,
      introduction:     described_class.attributes[:introduction].default,
      page_count:       nil,
      publication_date: nil,
      subtitle:         nil
    }
  end
  let(:initial_attributes) do
    {
      title:            'The Hobbit',
      isbn:             '978-3-16-148410-0',
      page_count:       250,
      publication_date: Date.new(1937, 9, 21)
    }
  end
  let(:expected_attributes) do
    default_attributes
      .merge(initial_attributes)
      .merge(id: be_a_uuid)
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  include_examples 'should define UUID primary key', :id

  include_examples 'should define attribute',
    :introduction,
    String,
    default: -> { default_attributes[:introduction] }

  include_examples 'should define attribute',
    :isbn,
    String,
    read_only: true

  include_examples 'should define attribute', :page_count, Integer

  include_examples 'should define attribute', :publication_date, Date

  include_examples 'should define attribute',
    :subtitle,
    String,
    allow_nil: true

  include_examples 'should define attribute', :title, String

  describe '::attributes' do
    it { expect(described_class).to respond_to(:attributes).with(0).arguments }

    describe 'with :banned_date' do
      it { expect(described_class.attributes[:banned_date]).to be nil }
    end

    describe 'with :rarity' do
      it { expect(described_class.attributes[:rarity]).to be nil }
    end
  end

  describe '::denormalize' do
    let(:expected) do
      {
        title:            nil,
        isbn:             nil,
        introduction:     nil,
        page_count:       nil,
        publication_date: nil,
        subtitle:         nil
      }
    end

    describe 'with nil' do
      let(:error_message) do
        'expected attributes to be a Hash, but was nil'
      end

      it 'should raise an error' do
        expect { described_class.denormalize(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      it 'should return an instance of the entity class' do
        expect(described_class.denormalize({})).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize({}).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize({}).primary_key).to be_a String
      end
    end

    describe 'with a hash with invalid string keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute "mystery"' }
      let(:attributes)    { { 'mystery' => mystery } }

      it 'should raise an error' do
        expect { described_class.denormalize(attributes) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a hash with invalid symbol keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute :mystery' }
      let(:attributes)    { { mystery: mystery } }

      it 'should raise an error' do
        expect { described_class.denormalize(attributes) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'            => 'The Hobbit',
          'subtitle'         => 'There And Back Again',
          'page_count'       => 200,
          'publication_date' => '1937-09-21'
        }
      end
      let(:expected) do
        {
          title:            'The Hobbit',
          page_count:       200,
          publication_date: Date.new(1937, 9, 21),
          subtitle:         'There And Back Again'
        }
      end

      it 'should return an instance of the entity class' do
        expect(described_class.denormalize(attributes)).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize(attributes).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize(attributes).primary_key)
          .to be_a String
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the attributes include a primary key' do
        let(:book_uuid)  { 'a6abad76-b312-435a-a0b4-133a5dd080f9' }
        let(:attributes) { super().merge('id' => book_uuid) }
        let(:expected)   { super().merge(id: book_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:            'The Hobbit',
          subtitle:         'There And Back Again',
          page_count:       200,
          publication_date: '1937-09-21'
        }
      end
      let(:expected) do
        {
          title:            'The Hobbit',
          page_count:       200,
          publication_date: Date.new(1937, 9, 21),
          subtitle:         'There And Back Again'
        }
      end

      it 'should return an instance of the entity class' do
        expect(described_class.denormalize(attributes)).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize(attributes).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize(attributes).primary_key)
          .to be_a String
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the attributes include a primary key' do
        let(:book_uuid)  { 'a6abad76-b312-435a-a0b4-133a5dd080f9' }
        let(:attributes) { super().merge(id: book_uuid) }
        let(:expected)   { super().merge(id: book_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end

  describe '#==' do
    # rubocop:disable Style/NilComparison
    describe 'with nil' do
      it { expect(book == nil).to be false }
    end
    # rubocop:enable Style/NilComparison

    describe 'with an Object' do
      it { expect(book == Object.new).to be false }
    end

    describe 'with an entity with a different class' do
      let(:other_entity_class) { Spec::OtherEntityClass }
      let(:other_entity)       { other_entity_class.new }

      example_class 'Spec::OtherEntityClass' do |klass|
        klass.send :include, Bronze::Entities::Attributes
      end

      it { expect(book == other_entity).to be false }
    end

    describe 'with an instance of a subclass' do
      let(:other_entity_class) { Class.new(described_class) }
      let(:other_entity)       { other_entity_class.new }

      it { expect(book == other_entity).to be false }
    end

    describe 'with a non-matching attributes hash' do
      let(:attributes) { book.attributes.merge(title: 'Green Eggs And Ham') }

      it { expect(book == attributes).to be false }
    end

    describe 'with a matching attributes hash' do
      let(:attributes) { book.attributes }

      it { expect(book == attributes).to be true }
    end

    describe 'with an entity with non-matching attributes' do
      let(:attributes)   { book.attributes.merge(title: 'Green Eggs And Ham') }
      let(:other_entity) { described_class.new(attributes) }

      it { expect(book == other_entity).to be false }
    end

    describe 'with an entity with matching attributes' do
      let(:attributes)   { book.attributes }
      let(:other_entity) { described_class.new(attributes) }

      it { expect(book == other_entity).to be true }
    end
  end

  describe '#assign_attributes' do
    it { expect(book).to respond_to(:assign_attributes).with(1).argument }

    describe 'with nil' do
      let(:error_message) do
        'expected attributes to be a Hash, but was nil'
      end

      it 'should raise an error' do
        expect { book.assign_attributes(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { book.assign_attributes({}) }
          .not_to change(book, :attributes)
      end
    end

    describe 'with a hash with invalid string keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute "mystery"' }
      let(:attributes)    { { 'mystery' => mystery } }

      it 'should raise an error' do
        expect { book.assign_attributes(attributes) }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.assign_attributes(attributes)
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with invalid symbol keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute :mystery' }
      let(:attributes) { { mystery: mystery } }

      it 'should raise an error' do
        expect { book.assign_attributes(attributes) }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.assign_attributes(attributes)
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.assign_attributes(attributes) }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.assign_attributes(attributes) }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#attribute?' do
    it { expect(book).to respond_to(:attribute?).with(1).argument }

    it { expect(book.attribute? :banned_date).to be false }

    it { expect(book.attribute? :rarity).to be false }
  end

  describe '#attributes' do
    let(:expected) do
      default_attributes
        .merge(initial_attributes)
        .merge(id: book.id)
    end

    it { expect(book).to respond_to(:attributes).with(0).arguments }

    it { expect(book.attributes).to be == expected }
  end

  describe '#attributes=' do
    it { expect(book).to respond_to(:attributes=).with(1).argument }

    describe 'with nil' do
      let(:error_message) do
        'expected attributes to be a Hash, but was nil'
      end

      it 'should raise an error' do
        expect { book.attributes = nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      let(:expected) do
        {
          id:               book.id,
          title:            nil,
          introduction:     nil,
          isbn:             nil,
          page_count:       nil,
          publication_date: nil,
          subtitle:         nil
        }
      end

      it 'should update the attributes' do
        expect { book.attributes = {} }
          .to change(book, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with invalid string keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute "mystery"' }
      let(:attributes)    { { 'mystery' => mystery } }

      it 'should raise an error' do
        expect { book.attributes = attributes }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.attributes = attributes
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with invalid symbol keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute :mystery' }
      let(:attributes)    { { mystery: mystery } }

      it 'should raise an error' do
        expect { book.attributes = attributes }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.attributes = attributes
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.attributes = attributes }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.attributes = attributes }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#get_attribute' do
    it { expect(book).to respond_to(:get_attribute).with(1).argument }

    describe 'with an invalid attribute name' do
      let(:error_message) { 'invalid attribute :banned_date' }

      it 'should raise an error' do
        expect { book.get_attribute(:banned_date) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a valid attribute name' do
      it 'should return the attribute' do
        expect(book.get_attribute(:title)).to be == initial_attributes[:title]
      end
    end
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::Book ' \
        "id: #{book.id.inspect}, " \
        "title: #{book.title.inspect}, " \
        "subtitle: #{book.subtitle.inspect}, " \
        "isbn: #{book.isbn.inspect}, " \
        "page_count: #{book.page_count.inspect}, " \
        "publication_date: #{book.publication_date.inspect}, " \
        "introduction: #{book.introduction.inspect}>"
    end

    it { expect(book.inspect).to be == expected }
  end

  describe '#normalize' do
    let(:expected_date) do
      transform = Bronze::Transforms::Attributes::DateTransform.instance

      transform.normalize(book.publication_date)
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:expected) do
      hsh =
        default_attributes
        .merge(initial_attributes)
        .merge(id: book.id)
        .merge(publication_date: expected_date)

      tools.hash.convert_keys_to_strings(hsh)
    end

    it { expect(book.normalize).to be == expected }
  end

  describe '#set_attribute' do
    it { expect(book).to respond_to(:set_attribute).with(2).arguments }

    describe 'with an invalid attribute name' do
      let(:error_message) { 'invalid attribute :banned_date' }

      it 'should raise an error' do
        expect { book.set_attribute(:banned_date, Date.today) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a valid attribute name' do
      let(:title) { 'The Silmarillion' }

      it 'should update the attribute' do
        expect { book.set_attribute(:title, title) }
          .to change { book.get_attribute(:title) }
          .to be == title
      end
    end
  end
end
