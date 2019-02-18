# frozen_string_literal: true

require 'support/entities/rare_book'
require 'support/examples/entity_examples'

RSpec.describe Spec::RareBook do
  include Spec::Support::Examples::EntityExamples

  subject(:rare_book) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      title:            nil,
      isbn:             nil,
      introduction:     described_class.attributes[:introduction].default,
      rarity:           nil,
      page_count:       nil,
      publication_date: nil,
      subtitle:         nil
    }
  end
  let(:initial_attributes) do
    {
      title:            'The Hobbit',
      isbn:             '978-3-16-148410-0',
      rarity:           'medium-rare',
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

  include_examples 'should define attribute', :rarity, String

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
  end

  describe '::denormalize' do
    let(:expected) do
      {
        title:            nil,
        isbn:             nil,
        introduction:     nil,
        page_count:       nil,
        publication_date: nil,
        rarity:           nil,
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

      context 'when the attributes include a primary key' do
        let(:book_uuid)  { 'a6abad76-b312-435a-a0b4-133a5dd080f9' }
        let(:attributes) { super().merge('id' => book_uuid) }
        let(:expected)   { super().merge(id: book_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
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

      context 'when the attributes include a primary key' do
        let(:book_uuid)  { 'a6abad76-b312-435a-a0b4-133a5dd080f9' }
        let(:attributes) { super().merge(id: book_uuid) }
        let(:expected)   { super().merge(id: book_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
    end
  end

  describe '#assign_attributes' do
    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { rare_book.assign_attributes({}) }
          .not_to change(rare_book, :attributes)
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'rarity'     => 'well-done',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.assign_attributes(attributes) }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          rarity:     'well-done',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.assign_attributes(attributes) }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#attribute?' do
    it { expect(rare_book.attribute? :banned_date).to be false }
  end

  describe '#attributes' do
    let(:expected) do
      default_attributes
        .merge(initial_attributes)
        .merge(id: rare_book.id)
    end

    it { expect(rare_book.attributes).to be == expected }
  end

  describe '#attributes=' do
    describe 'with an empty hash' do
      let(:expected) do
        {
          id:               rare_book.id,
          title:            nil,
          introduction:     nil,
          isbn:             nil,
          page_count:       nil,
          publication_date: nil,
          rarity:           nil,
          subtitle:         nil
        }
      end

      it 'should update the attributes' do
        expect { rare_book.attributes = {} }
          .to change(rare_book, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'rarity'     => 'well-done',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.attributes = attributes }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          rarity:     'well-done',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.attributes = attributes }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::RareBook ' \
        "id: #{rare_book.id.inspect}, " \
        "title: #{rare_book.title.inspect}, " \
        "subtitle: #{rare_book.subtitle.inspect}, " \
        "isbn: #{rare_book.isbn.inspect}, " \
        "page_count: #{rare_book.page_count.inspect}, " \
        "publication_date: #{rare_book.publication_date.inspect}, " \
        "introduction: #{rare_book.introduction.inspect}, " \
        "rarity: #{rare_book.rarity.inspect}>"
    end

    it { expect(rare_book.inspect).to be == expected }
  end

  describe '#normalize' do
    let(:expected_date) do
      transform = Bronze::Transforms::Attributes::DateTransform.instance

      transform.normalize(rare_book.publication_date)
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:expected) do
      hsh =
        default_attributes
        .merge(initial_attributes)
        .merge(id: rare_book.id)
        .merge(publication_date: expected_date)

      tools.hash.convert_keys_to_strings(hsh)
    end

    it { expect(rare_book.normalize).to be == expected }
  end
end
