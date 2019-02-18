# frozen_string_literal: true

require 'bronze/errors'

RSpec.describe Bronze::Errors do
  shared_context 'with error data' do
    let(:error_data) do
      {
        'spec.errors.present'              => {},
        'spec.errors.numeric'              => {},
        'spec.errors.numeric.greater_than' => { value: 0 }
      }
    end

    def add_errors(errors, data)
      data.each { |type, params| errors.add(type, **params) }
    end
  end

  shared_context 'with nested error data' do
    let(:nested_error_data) do
      {
        []                              => {
          'spec.errors.unable_to_connect_to_server' => {}
        },
        [:articles]                     => {
          'spec.errors.authorization.unauthorized' => {}
        },
        [:articles, 0, :id]             => {
          'spec.errors.present'              => {},
          'spec.errors.numeric'              => {},
          'spec.errors.numeric.greater_than' => { value: 0 }
        },
        [:articles, 0, :tags]           => {
          'spec.errors.present' => {}
        },
        [:articles, 1, :tags, 0, :name] => {
          'spec.errors.already_exists' => { value: 'Favorite Color' }
        },
        [:articles, 1, :tags, 1, :name] => {
          'spec.errors.language.profanity' => { language: 'Quenya' }
        }
      }
    end

    def add_nested_errors(errors, nested_data)
      nested_data.each do |path, data|
        nested_errors = errors.dig(*path)

        data.each { |type, params| nested_errors.add(type, **params) }
      end
    end
  end

  shared_context 'when there are many errors' do
    include_context 'with error data'

    let(:expected_errors) do
      error_data.map do |type, params|
        {
          type:   type,
          params: params,
          path:   path
        }
      end
    end

    before(:example) do
      add_errors(errors, error_data)
    end
  end

  shared_context 'when there are many nested errors' do
    include_context 'with nested error data'

    let(:expected_errors) do
      nested_error_data.map do |nested_path, nested_data|
        nested_data.map do |type, params|
          {
            type:   type,
            params: params,
            path:   path + nested_path
          }
        end
      end.flatten
    end

    before(:example) do
      add_nested_errors(errors, nested_error_data)
    end
  end

  shared_context 'when the path has many ancestors' do
    let(:path) { [:articles, 0, :tags] }
  end

  subject(:errors) { described_class.new(path: path) }

  let(:path)            { [] }
  let(:expected_errors) { [] }

  it { expect(described_class).to be < Enumerable }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:data, :path)
    end
  end

  describe '#==' do
    shared_context 'with an errors object with many errors' do
      include_context 'with error data'

      before(:example) { add_errors(other, error_data) }
    end

    shared_context 'with an errors object with many nested errors' do
      include_context 'with nested error data'

      before(:example) { add_nested_errors(other, nested_error_data) }
    end

    let(:other) { described_class.new path: path }

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(errors == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an empty array' do
      it { expect(errors == []).to be true }
    end

    describe 'with an empty errors object' do
      it { expect(errors == other).to be true }

      it { expect(errors == other.to_a).to be true }
    end

    wrap_context 'with an errors object with many errors' do
      it { expect(errors == other).to be false }

      it { expect(errors == other.to_a).to be false }
    end

    wrap_context 'with an errors object with many nested errors' do
      it { expect(errors == other).to be false }

      it { expect(errors == other.to_a).to be false }
    end

    wrap_context 'when there are many errors' do
      describe 'with an empty errors object' do
        it { expect(errors == other).to be false }

        it { expect(errors == other.to_a).to be false }
      end

      describe 'with an errors object with unordered errors' do
        include_context 'with error data'

        before(:example) do
          error_data.reverse_each do |error_type, error_params|
            other.add error_type, **error_params
          end
        end

        it { expect(errors == other).to be true }

        it { expect(errors == other.to_a).to be true }
      end

      wrap_context 'with an errors object with many errors' do
        it { expect(errors == other).to be true }

        it { expect(errors == other.to_a).to be true }
      end

      wrap_context 'with an errors object with many nested errors' do
        it { expect(errors == other).to be false }

        it { expect(errors == other.to_a).to be false }
      end
    end

    wrap_context 'when there are many nested errors' do
      describe 'with an empty errors object' do
        it { expect(errors == other).to be false }

        it { expect(errors == other.to_a).to be false }
      end

      wrap_context 'with an errors object with many errors' do
        it { expect(errors == other).to be false }

        it { expect(errors == other.to_a).to be false }
      end

      wrap_context 'with an errors object with many nested errors' do
        it { expect(errors == other).to be true }

        it { expect(errors == other.to_a).to be true }
      end
    end
  end

  describe '#[]' do
    let(:key)    { :title }
    let(:type)   { 'spec.errors.custom_error' }
    let(:params) { {} }
    let(:expected) do
      expected_key = key.is_a?(String) ? key.intern : key

      {
        type:   type,
        params: params,
        path:   path + [expected_key]
      }
    end

    it { expect(errors).to respond_to(:[]).with(1).argument }

    it { expect(errors[key]).to be_a described_class }

    it { expect(errors[key].send(:path)).to be == path + [key] }

    it 'should reference the inner data structure' do
      expect { errors[key].add type }
        .to change(errors, :to_a)
        .to include(expected)
    end

    describe 'with an integer' do
      let(:key) { 0 }

      it { expect(errors[key]).to be_a described_class }

      it { expect(errors[key].send(:path)).to be == path + [key] }

      it 'should reference the inner data structure' do
        expect { errors[key].add type }
          .to change(errors, :to_a)
          .to include(expected)
      end
    end

    describe 'with a string' do
      let(:key) { 'title' }

      it { expect(errors[key]).to be_a described_class }

      it { expect(errors[key].send(:path)).to be == path + [key.intern] }

      it 'should reference the inner data structure' do
        expect { errors[key].add type }
          .to change(errors, :to_a)
          .to include(expected)
      end
    end

    wrap_context 'when the path has many ancestors' do
      it { expect(errors[key]).to be_a described_class }

      it { expect(errors[key].send(:path)).to be == path + [key] }

      it 'should reference the inner data structure' do
        expect { errors[key].add type }
          .to change(errors, :to_a)
          .to include(expected)
      end
    end
  end

  describe '#[]=' do
    include_context 'with nested error data'

    shared_examples 'should copy the hash into the data' do
      it 'should add the errors to the data' do
        expect { errors[key] = value }
          .to change(errors, :count)
          .to be expected_count
      end

      it 'should set the relative path' do
        errors[key] = value

        expect(errors).to include expected_error
      end

      it 'should copy the data' do
        errors[key] = value

        expect { other.add :custom_error }.not_to change(errors, :count)
      end
    end

    let(:key)            { :connection }
    let(:other)          { described_class.new }
    let(:expected_count) { other.count }
    let(:expected_error) do
      {
        type:   'spec.errors.language.profanity',
        params: { language: 'Quenya' },
        path:   [*path, key, :articles, 1, :tags, 1, :name]
      }
    end

    before(:example) { add_nested_errors(other, nested_error_data) }

    it { expect(errors).to respond_to(:[]=).with(2).arguments }

    describe 'with an errors object' do
      let(:value) { other }

      include_examples 'should copy the hash into the data'
    end

    describe 'with a hash' do
      let(:value) { other.send :data }

      include_examples 'should copy the hash into the data'
    end

    wrap_context 'when the path has many ancestors' do
      describe 'with an errors object' do
        let(:value) { other }

        include_examples 'should copy the hash into the data'
      end

      describe 'with a hash' do
        let(:value) { other.send :data }

        include_examples 'should copy the hash into the data'
      end
    end
  end

  describe '#add' do
    let(:type)   { 'spec.errors.custom_error' }
    let(:params) { {} }
    let(:expected) do
      {
        type:   type.to_s,
        params: params,
        path:   path
      }
    end

    it { expect(errors).to respond_to(:add).with(1..2).arguments }

    it 'should add the error' do
      expect { errors.add type }
        .to change(errors, :to_a)
        .to include(expected)
    end

    it 'should return the proxy' do
      expect(errors.add type).to be errors
    end

    describe 'when the error type is a Symbol' do
      let(:type) { :custom_error }

      it 'should add the error' do
        expect { errors.add type }
          .to change(errors, :to_a)
          .to include(expected)
      end
    end

    describe 'with custom params' do
      let(:params) { { key: 'value' } }

      it 'should add the error' do
        expect { errors.add type, params }
          .to change(errors, :to_a)
          .to include(expected)
      end
    end

    wrap_context 'when the path has many ancestors' do
      it 'should add the error' do
        expect { errors.add type }
          .to change(errors, :to_a)
          .to include(expected)
      end

      describe 'with custom params' do
        let(:params) { { key: 'value' } }

        it 'should add the error' do
          expect { errors.add type, params }
            .to change(errors, :to_a)
            .to include(expected)
        end
      end
    end
  end

  describe '#clear' do
    it { expect(errors).to respond_to(:clear).with(0).arguments }

    it { expect(errors.clear).to be errors }

    it { expect { errors.clear }.not_to change(errors, :to_a) }

    wrap_context 'when there are many errors' do
      it { expect { errors.clear }.to change(errors, :count).to be 0 }

      it { expect { errors.clear }.to change(errors, :to_a).to be == [] }
    end

    wrap_context 'when there are many nested errors' do
      it { expect { errors.clear }.to change(errors, :count).to be 0 }

      it { expect { errors.clear }.to change(errors, :to_a).to be == [] }
    end
  end

  describe '#count' do
    it { expect(errors).to respond_to(:count).with(0).arguments }

    it { expect(errors.count).to be 0 }

    it { expect(errors).to alias_method(:count).as(:length) }

    it { expect(errors).to alias_method(:count).as(:size) }

    wrap_context 'when there are many errors' do
      it { expect(errors.count).to be == expected_errors.count }
    end

    wrap_context 'when there are many nested errors' do
      it { expect(errors.count).to be == expected_errors.count }
    end
  end

  describe '#delete' do
    let(:key)  { :title }
    let(:type) { 'spec.errors.custom_error' }

    it { expect(errors).to respond_to(:delete).with(1).arguments }

    it { expect(errors.delete(key)).to be_a described_class }

    it { expect(errors.delete(key).send(:path)).to be == [] }

    it 'should not reference the inner data structure' do
      proxy = errors.delete(key)

      expect { proxy.add type }.not_to change(errors, :to_a)
    end

    wrap_context 'when there are many nested errors' do
      let(:key) { :articles }

      it { expect(errors).to respond_to(:delete).with(1).arguments }

      it { expect(errors.delete(key)).to be_a described_class }

      it { expect(errors.delete(key).send(:path)).to be == [] }

      it 'should not reference the inner data structure' do
        proxy = errors.delete(key)

        expect { proxy.add type }.not_to change(errors, :to_a)
      end

      it 'should remove the referenced data' do
        expect { errors.delete(key) }.to change(errors, :count).to be 1
      end
    end
  end

  describe '#dig' do
    let(:key)    { :title }
    let(:type)   { 'spec.errors.custom_error' }
    let(:params) { {} }
    let(:expected) do
      expected_key = key.is_a?(String) ? key.intern : key

      {
        type:   type,
        params: params,
        path:   path + [expected_key]
      }
    end

    it { expect(errors).to respond_to(:dig).with_unlimited_arguments }

    it { expect(errors).to respond_to(:[]).with(1).argument }

    it { expect(errors.dig(key)).to be_a described_class }

    it { expect(errors.dig(key).send(:path)).to be == path + [key] }

    it 'should reference the inner data structure' do
      expect { errors.dig(key).add type }
        .to change(errors, :to_a)
        .to include(expected)
    end

    describe 'with many keys' do
      let(:keys) { %i[properties location latitude] }
      let(:expected) do
        {
          type:   type,
          params: params,
          path:   path + keys
        }
      end

      it 'should reference the inner data structure' do
        expect { errors.dig(*keys).add type }
          .to change(errors, :to_a)
          .to include(expected)
      end
    end

    wrap_context 'when the path has many ancestors' do
      it { expect(errors.dig(key)).to be_a described_class }

      it { expect(errors.dig(key).send(:path)).to be == path + [key] }

      it 'should reference the inner data structure' do
        expect { errors.dig(key).add type }
          .to change(errors, :to_a)
          .to include(expected)
      end

      describe 'with many keys' do
        let(:keys) { %i[properties location latitude] }
        let(:expected) do
          {
            type:   type,
            params: params,
            path:   path + keys
          }
        end

        it 'should reference the inner data structure' do
          expect { errors.dig(*keys).add type }
            .to change(errors, :to_a)
            .to include(expected)
        end
      end
    end
  end

  describe '#dup' do
    shared_examples 'should return a copy of the errors' do
      let(:copy) { errors.dup }

      it { expect(copy).to be_a described_class }

      it { expect(copy.count).to be expected_errors.size }

      it { expect(copy.to_a).to be == expected_errors }

      it { expect(copy.send(:path)).to be == path }

      it 'should not change the original errors' do
        expect { copy.add 'spec.errors.system.unable_to_run_command_com' }
          .not_to change(errors, :count)
      end

      it 'should not change the original nested errors' do
        error_type = 'spec.errors.time.must_include_mayan_calendar_date'

        expect { copy[:articles][0][:slug].add error_type }
          .not_to change(errors, :count)
      end
    end

    it { expect(errors).to respond_to(:dup).with(0).arguments }

    include_examples 'should return a copy of the errors'

    wrap_context 'when there are many errors' do
      include_examples 'should return a copy of the errors'

      wrap_context 'when the path has many ancestors' do
        include_examples 'should return a copy of the errors'
      end
    end

    wrap_context 'when there are many nested errors' do
      include_examples 'should return a copy of the errors'

      wrap_context 'when the path has many ancestors' do
        include_examples 'should return a copy of the errors'
      end
    end

    context 'with a subclass of Bronze::Errors' do
      let(:described_class) { Spec::CustomErrors }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::CustomErrors', Bronze::Errors
      # rubocop:enable RSpec/DescribedClass

      include_examples 'should return a copy of the errors'

      wrap_context 'when there are many errors' do
        include_examples 'should return a copy of the errors'

        wrap_context 'when the path has many ancestors' do
          include_examples 'should return a copy of the errors'
        end
      end

      wrap_context 'when there are many nested errors' do
        include_examples 'should return a copy of the errors'

        wrap_context 'when the path has many ancestors' do
          include_examples 'should return a copy of the errors'
        end
      end
    end
  end

  describe '#each' do
    it { expect(errors).to respond_to(:each).with(0).arguments }

    it { expect(errors.each).to be_a Enumerator }

    it 'should return an enumerator' do
      enumerator = errors.each
      yielded    = []

      enumerator.each { |error| yielded << error }

      expect(yielded).to be == []
    end

    it 'should yield each error' do
      yielded = []

      errors.each { |error| yielded << error }

      expect(yielded).to be == []
    end

    wrap_context 'when there are many errors' do
      it 'should return an enumerator' do
        enumerator = errors.each
        yielded    = []

        enumerator.each { |error| yielded << error }

        expect(yielded).to be == expected_errors
      end

      it 'should yield each error' do
        yielded = []

        errors.each { |error| yielded << error }

        expect(yielded).to be == expected_errors
      end

      wrap_context 'when the path has many ancestors' do
        it 'should return an enumerator' do
          enumerator = errors.each
          yielded    = []

          enumerator.each { |error| yielded << error }

          expect(yielded).to be == expected_errors
        end

        it 'should yield each error' do
          yielded = []

          errors.each { |error| yielded << error }

          expect(yielded).to be == expected_errors
        end
      end
    end

    wrap_context 'when there are many nested errors' do
      it 'should return an enumerator' do
        enumerator = errors.each
        yielded    = []

        enumerator.each { |error| yielded << error }

        expect(yielded).to be == expected_errors
      end

      it 'should yield each error' do
        yielded = []

        errors.each { |error| yielded << error }

        expect(yielded).to be == expected_errors
      end

      wrap_context 'when the path has many ancestors' do
        it 'should return an enumerator' do
          enumerator = errors.each
          yielded    = []

          enumerator.each { |error| yielded << error }

          expect(yielded).to be == expected_errors
        end

        it 'should yield each error' do
          yielded = []

          errors.each { |error| yielded << error }

          expect(yielded).to be == expected_errors
        end
      end
    end
  end

  describe '#empty?' do
    it { expect(errors).to have_predicate(:empty?).with_value(true) }

    wrap_context 'when there are many errors' do
      it { expect(errors.empty?).to be false }
    end

    wrap_context 'when there are many nested errors' do
      it { expect(errors.empty?).to be false }
    end
  end

  describe '#include?' do
    let(:type) { 'spec.errors.numeric.greater_than' }

    it { expect(errors).to respond_to(:include?).with(1).argument }

    describe 'with an error type' do
      it { expect(errors.include? type).to be false }
    end

    describe 'with an error hash' do
      it { expect(errors.include? type: type).to be false }
    end

    wrap_context 'when there are many errors' do
      describe 'with a non-matching error type' do
        let(:type) { 'spec.errors.numeric.divide_by_zero' }

        it { expect(errors.include? type).to be false }
      end

      describe 'with a matching error type' do
        it { expect(errors.include? type).to be true }
      end

      describe 'with a non-matching error hash' do
        let(:expected) do
          { type: type, params: { value: Float::INFINITY } }
        end

        it { expect(errors.include? expected).to be false }
      end

      describe 'with a matching error hash' do
        let(:expected) do
          { type: type, params: { value: 0 } }
        end

        it { expect(errors.include? expected).to be true }
      end
    end

    wrap_context 'when there are many nested errors' do
      describe 'with a non-matching error type' do
        it { expect(errors.include? :divide_by_zero).to be false }
      end

      describe 'with a matching error type' do
        it { expect(errors.include? type).to be true }
      end

      describe 'with a non-matching error hash' do
        let(:expected) do
          { type: type, params: { value: Float::INFINITY } }
        end

        it { expect(errors.include? expected).to be false }
      end

      describe 'with a matching error hash' do
        let(:expected) do
          { type: type, params: { value: 0 } }
        end

        it { expect(errors.include? expected).to be true }
      end

      describe 'with a matching error hash with non-matching path' do
        let(:expected) do
          { type: type, params: { value: 0 }, path: [] }
        end

        it { expect(errors.include? expected).to be false }
      end

      describe 'with a matching error hash with matching path' do
        let(:expected) do
          {
            type:   type,
            params: { value: 0 },
            path:   [:articles, 0, :id]
          }
        end

        it { expect(errors.include? expected).to be true }
      end
    end
  end

  describe '#key?' do
    it { expect(errors).to respond_to(:key?).with(1).argument }

    it { expect(errors).to alias_method(:key?).as(:has_key?) }

    it { expect(errors.key? :articles).to be false }

    wrap_context 'when there are many errors' do
      it { expect(errors.key? :articles).to be false }
    end

    wrap_context 'when there are many nested errors' do
      it { expect(errors.key? :articles).to be true }

      it { expect(errors.key? :books).to be false }

      describe 'with an integer' do
        it { expect(errors[:articles].key? 1).to be true }

        it { expect(errors[:articles].key? 2).to be false }
      end

      describe 'with a string' do
        it { expect(errors.key? 'articles').to be true }

        it { expect(errors.key? 'books').to be false }
      end
    end
  end

  describe '#keys' do
    it { expect(errors).to respond_to(:keys).with(0).arguments }

    it { expect(errors.keys).to be == [] }

    wrap_context 'when there are many errors' do
      it { expect(errors.keys).to be == [] }
    end

    wrap_context 'when there are many nested errors' do
      it { expect(errors.keys).to be == [:articles] }

      it { expect(errors[:articles].keys).to be == [0, 1] }
    end
  end

  describe '#merge' do
    let(:other)  { described_class.new }
    let(:merged) { errors.merge(other) }

    it { expect(errors).to respond_to(:merge).with(1).argument }

    it { expect(errors.merge other).to be_a described_class }

    it { expect(errors.merge other).not_to be errors }

    describe 'with an empty errors object' do
      it { expect { errors.merge other }.not_to change(errors, :to_a) }

      it { expect(merged.to_a).to be == expected_errors }
    end

    describe 'with an errors object with errors' do
      let(:other) do
        super().tap { |errors| errors.add 'spec.errors.uniqueness' }
      end

      it { expect { errors.merge other }.not_to change(errors, :to_a) }

      it { expect(merged).to include('spec.errors.uniqueness') }
    end

    describe 'with an errors object with nested errors' do
      let(:other) do
        super().tap do |errors|
          errors
            .add 'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
          errors[:authorization][:api_key]
            .add 'spec.errors.numeric.must_be_prime_in_base_13'
          errors[:articles][0][:title]
            .add 'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
        end
      end

      it { expect { errors.merge other }.not_to change(errors, :to_a) }

      it 'should add the top-level errors to the merged errors' do
        expect(merged).to include(
          'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
        )
      end

      it 'should add the integer-scoped errors to the merged errors' do
        expect(merged[:articles][0][:title]).to include(
          'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
        )
      end

      it 'should add the symbol-scoped errors to the merged errors' do
        expect(merged[:authorization][:api_key]).to include(
          'spec.errors.numeric.must_be_prime_in_base_13'
        )
      end
    end

    wrap_context 'when there are many errors' do
      describe 'with an empty errors object' do
        it { expect { errors.merge other }.not_to change(errors, :to_a) }

        it { expect(merged.to_a).to be == expected_errors }
      end

      describe 'with an errors object with errors' do
        let(:other) do
          super().tap { |errors| errors.add 'spec.errors.uniqueness' }
        end

        it { expect { errors.merge other }.not_to change(errors, :to_a) }

        it { expect(merged).to include('spec.errors.uniqueness') }
      end

      describe 'with an errors object with nested errors' do
        let(:other) do
          super().tap do |errors|
            errors
              .add 'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
            errors[:authorization][:api_key]
              .add 'spec.errors.numeric.must_be_prime_in_base_13'
            errors[:articles][0][:title]
              .add 'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          end
        end

        it { expect { errors.merge other }.not_to change(errors, :to_a) }

        it 'should add the top-level errors to the merged errors' do
          expect(merged).to include(
            'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
          )
        end

        it 'should add the integer-scoped errors to the merged errors' do
          expect(merged[:articles][0][:title]).to include(
            'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          )
        end

        it 'should add the symbol-scoped errors to the merged errors' do
          expect(merged[:authorization][:api_key]).to include(
            'spec.errors.numeric.must_be_prime_in_base_13'
          )
        end
      end
    end

    wrap_context 'when there are many nested errors' do
      describe 'with an empty errors object' do
        it { expect { errors.merge other }.not_to change(errors, :to_a) }

        it { expect(merged.to_a).to be == expected_errors }
      end

      describe 'with an errors object with errors' do
        let(:other) do
          super().tap { |errors| errors.add 'spec.errors.uniqueness' }
        end

        it { expect { errors.merge other }.not_to change(errors, :to_a) }

        it { expect(merged).to include('spec.errors.uniqueness') }
      end

      describe 'with an errors object with nested errors' do
        let(:other) do
          super().tap do |errors|
            errors
              .add 'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
            errors[:authorization][:api_key]
              .add 'spec.errors.numeric.must_be_prime_in_base_13'
            errors[:articles][0][:title]
              .add 'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          end
        end

        it { expect { errors.merge other }.not_to change(errors, :to_a) }

        it 'should add the top-level errors to the merged errors' do
          expect(merged).to include(
            'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
          )
        end

        it 'should add the integer-scoped errors to the merged errors' do
          expect(merged[:articles][0][:title]).to include(
            'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          )
        end

        it 'should add the symbol-scoped errors to the merged errors' do
          expect(merged[:authorization][:api_key]).to include(
            'spec.errors.numeric.must_be_prime_in_base_13'
          )
        end
      end
    end
  end

  describe '#to_a' do
    it { expect(errors).to respond_to(:to_a).with(0).arguments }

    it { expect(errors.to_a).to be == [] }

    wrap_context 'when there are many errors' do
      it { expect(errors.to_a).to be == expected_errors }

      wrap_context 'when the path has many ancestors' do
        it { expect(errors.to_a).to be == expected_errors }
      end
    end

    wrap_context 'when there are many nested errors' do
      it { expect(errors.to_a).to be == expected_errors }

      wrap_context 'when the path has many ancestors' do
        it { expect(errors.to_a).to deep_match expected_errors }
      end
    end
  end

  describe '#update' do
    let(:other) { described_class.new }

    it { expect(errors).to respond_to(:update).with(1).argument }

    it { expect(errors.update other).to be errors }

    describe 'with an empty errors object' do
      it { expect { errors.update other }.not_to change(errors, :count) }
    end

    describe 'with an errors object with errors' do
      let(:other) do
        super().tap { |errors| errors.add 'spec.errors.uniqueness' }
      end

      it { expect { errors.update other }.to change(errors, :count).by(1) }

      it 'should add the errors to the object' do
        errors.update other

        expect(errors).to include('spec.errors.uniqueness')
      end
    end

    describe 'with an errors object with nested errors' do
      let(:other) do
        super().tap do |errors|
          errors
            .add 'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
          errors[:authorization][:api_key]
            .add 'spec.errors.numeric.must_be_prime_in_base_13'
          errors[:articles][0][:title]
            .add 'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
        end
      end

      it { expect { errors.update other }.to change(errors, :count).by(3) }

      it 'should add the top-level errors to the object' do
        errors.update other

        expect(errors).to include(
          'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
        )
      end

      it 'should add the integer-scoped errors to the object' do
        errors.update other

        expect(errors[:articles][0][:title]).to include(
          'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
        )
      end

      it 'should add the symbol-scoped errors to the object' do
        errors.update other

        expect(errors[:authorization][:api_key]).to include(
          'spec.errors.numeric.must_be_prime_in_base_13'
        )
      end
    end

    wrap_context 'when there are many errors' do
      describe 'with an empty errors object' do
        it { expect { errors.update other }.not_to change(errors, :count) }
      end

      describe 'with an errors object with errors' do
        let(:other) do
          super().tap { |errors| errors.add 'spec.errors.uniqueness' }
        end

        it { expect { errors.update other }.to change(errors, :count).by(1) }

        it 'should add the errors to the object' do
          errors.update other

          expect(errors).to include('spec.errors.uniqueness')
        end
      end

      describe 'with an errors object with nested errors' do
        let(:other) do
          super().tap do |errors|
            errors
              .add 'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
            errors[:authorization][:api_key]
              .add 'spec.errors.numeric.must_be_prime_in_base_13'
            errors[:articles][0][:title]
              .add 'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          end
        end

        it { expect { errors.update other }.to change(errors, :count).by(3) }

        it 'should add the top-level errors to the object' do
          errors.update other

          expect(errors).to include(
            'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
          )
        end

        it 'should add the integer-scoped errors to the object' do
          errors.update other

          expect(errors[:articles][0][:title]).to include(
            'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          )
        end

        it 'should add the symbol-scoped errors to the object' do
          errors.update other

          expect(errors[:authorization][:api_key]).to include(
            'spec.errors.numeric.must_be_prime_in_base_13'
          )
        end
      end
    end

    wrap_context 'when there are many nested errors' do
      describe 'with an empty errors object' do
        it { expect { errors.update other }.not_to change(errors, :count) }
      end

      describe 'with an errors object with errors' do
        let(:other) do
          super().tap { |errors| errors.add 'spec.errors.uniqueness' }
        end

        it { expect { errors.update other }.to change(errors, :count).by(1) }

        it 'should add the errors to the object' do
          errors.update other

          expect(errors).to include('spec.errors.uniqueness')
        end
      end

      describe 'with an errors object with nested errors' do
        let(:other) do
          super().tap do |errors|
            errors
              .add 'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
            errors[:authorization][:api_key]
              .add 'spec.errors.numeric.must_be_prime_in_base_13'
            errors[:articles][0][:title]
              .add 'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          end
        end

        it { expect { errors.update other }.to change(errors, :count).by(3) }

        it 'should add the top-level errors to the object' do
          errors.update other

          expect(errors).to include(
            'spec.errors.mystic.must_sacrifice_ungulate_to_server_daemon'
          )
        end

        it 'should add the integer-scoped errors to the object' do
          errors.update other

          expect(errors[:articles][0][:title]).to include(
            'spec.errors.fandom.twilight_fanfic_strictly_prohibited'
          )
        end

        it 'should add the symbol-scoped errors to the object' do
          errors.update other

          expect(errors[:authorization][:api_key]).to include(
            'spec.errors.numeric.must_be_prime_in_base_13'
          )
        end
      end
    end
  end
end
