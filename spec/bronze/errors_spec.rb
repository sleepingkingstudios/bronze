# spec/bronze/errors_spec.rb

require 'bronze/errors'

RSpec.describe Bronze::Errors do
  shared_context 'when there are many errors' do
    let(:errors) do
      {
        :must_be_present      => {},
        :must_be_numeric      => {},
        :must_be_greater_than => { :value => 0 }
      } # end hash
    end # let

    before(:example) do
      errors.each do |error_type, error_params|
        instance.add error_type, **error_params
      end # each
    end # before example
  end # shared_context

  shared_context 'when there are many nested errors' do
    let(:nested_errors) do
      {
        [] => {
          :unable_to_connect_to_server => {}
        }, # end root errors
        [:articles] => {
          :unauthorized => {}
        }, # end articles count errors
        [:articles, 0, :id] => {
          :must_be_present      => {},
          :must_be_numeric      => {},
          :must_be_greater_than => { :value => 0 }
        }, # end articles 0 id errors
        [:articles, 0, :tags] => {
          :must_be_present => {}
        }, # end articles 0 tags errors
        [:articles, 1, :tags, 0, :name] => {
          :already_exists => { :value => 'Favorite Color' }
        }, # end articles 1 tags 0 errors
        [:articles, 1, :tags, 1, :name] => {
          :profanity => { :language => 'Quenya' }
        } # end articles 1 tags 1 errors
      } # end errors
    end # let

    before(:example) do
      nested_errors.each do |path, errors|
        proxy = instance.dig(*path)

        errors.each do |error_type, error_params|
          proxy.add error_type, **error_params
        end # each
      end # each
    end # before example
  end # shared_context

  shared_context 'when the path has many ancestors' do
    let(:path) { [:articles, 0, :tags] }
  end # shared_context

  let(:path)     { [] }
  let(:instance) { described_class.new :path => path }

  it 'should include Enumerable' do
    expect(described_class).to be < Enumerable
  end # it

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0).arguments.
        and_keywords(:data, :path)
    end # it
  end # describe

  describe '#[]' do
    let(:key)    { :title }
    let(:type)   { :custom_error }
    let(:params) { {} }
    let(:expected) do
      {
        :type   => type,
        :params => params,
        :path   => path + [key]
      } # end error
    end # let

    it { expect(instance).to respond_to(:[]).with(1).argument }

    it 'should return an errors proxy' do
      proxy = instance[key]

      expect(proxy).to be_a described_class
      expect(proxy.send :path).to be == path + [key]
    end # it

    it 'should reference the inner data structure' do
      expect { instance[key].add type }.
        to change(instance, :to_a).
        to include(expected)
    end # it

    describe 'with an integer' do
      let(:key) { 0 }

      it 'should return an errors proxy' do
        proxy = instance[key]

        expect(proxy).to be_a described_class
        expect(proxy.send :path).to be == [key]
      end # it
    end # describe

    describe 'with a string' do
      let(:key) { 'title' }

      it 'should return an errors proxy' do
        proxy = instance[key]

        expect(proxy).to be_a described_class
        expect(proxy.send :path).to be == [key.intern]
      end # it
    end # describe

    wrap_context 'when the path has many ancestors' do
      it 'should return an errors proxy' do
        proxy = instance[key]

        expect(proxy).to be_a described_class
        expect(proxy.send :path).to be == path + [key]
      end # it

      it 'should reference the inner data structure' do
        expect { instance[key].add type }.
          to change(instance, :to_a).
          to include(expected)
      end # it
    end # wrap_context
  end # describe

  describe '#[]=' do
    shared_examples 'should copy the hash into the data' do
      it 'should add the errors to the data' do
        expect { instance[key] = value }.
          to change(instance, :count).
          to be expected_count
      end # it

      it 'should set the relative path' do
        instance[key] = value

        expect(instance).to include expected_error
      end # it

      it 'should copy the data' do
        instance[key] = value

        expect { other_proxy.add :custom_error }.not_to change(instance, :count)
      end # it
    end # shared_examples

    let(:key) { :connection }
    let(:nested_errors) do
      {
        [] => {
          :unable_to_connect_to_server => {}
        }, # end root errors
        [:articles] => {
          :unauthorized => {}
        }, # end articles count errors
        [:articles, 0, :id] => {
          :must_be_present      => {},
          :must_be_numeric      => {},
          :must_be_greater_than => { :value => 0 }
        }, # end articles 0 id errors
        [:articles, 0, :tags] => {
          :must_be_present => {}
        }, # end articles 0 tags errors
        [:articles, 1, :tags, 0, :name] => {
          :already_exists => { :value => 'Favorite Color' }
        }, # end articles 1 tags 0 errors
        [:articles, 1, :tags, 1, :name] => {
          :profanity => { :language => 'Quenya' }
        } # end articles 1 tags 1 errors
      } # end errors
    end # let
    let(:other_proxy) do
      other = described_class.new

      nested_errors.each do |path, errors|
        proxy = other.dig(*path)

        errors.each do |error_type, error_params|
          proxy.add error_type, **error_params
        end # each
      end # each

      other
    end # let
    let(:expected_count) do
      nested_errors.reduce(0) { |memo, (_, hsh)| memo + hsh.size }
    end # let
    let(:expected_error) do
      {
        :type   => :profanity,
        :params => { :language => 'Quenya' },
        :path   => [*path, key, :articles, 1, :tags, 1, :name]
      } # end error
    end # let

    it { expect(instance).to respond_to(:[]=).with(2).arguments }

    describe 'with an errors object' do
      let(:value) { other_proxy }

      include_examples 'should copy the hash into the data'
    end # describe

    describe 'with a hash' do
      let(:value) { other_proxy.send :data }

      include_examples 'should copy the hash into the data'
    end # describe

    wrap_context 'when the path has many ancestors' do
      describe 'with an errors object' do
        let(:value) { other_proxy }

        include_examples 'should copy the hash into the data'
      end # describe

      describe 'with a hash' do
        let(:value) { other_proxy.send :data }

        include_examples 'should copy the hash into the data'
      end # describe
    end # wrap_context
  end # describe

  describe '#add' do
    let(:type)   { :custom_error }
    let(:params) { {} }
    let(:expected) do
      {
        :type   => type,
        :params => params,
        :path   => path
      } # end error
    end # let

    it { expect(instance).to respond_to(:add).with(1..2).arguments }

    it 'should add the error' do
      expect { instance.add type }.
        to change(instance, :to_a).
        to include(expected)
    end # it

    it 'should return the proxy' do
      expect(instance.add type).to be instance
    end # it

    describe 'with custom params' do
      let(:params) { { :key => 'value' } }

      it 'should add the error' do
        expect { instance.add type, params }.
          to change(instance, :to_a).
          to include(expected)
      end # it
    end # describe

    wrap_context 'when the path has many ancestors' do
      it 'should add the error' do
        expect { instance.add type }.
          to change(instance, :to_a).
          to include(expected)
      end # it

      describe 'with custom params' do
        let(:params) { { :key => 'value' } }

        it 'should add the error' do
          expect { instance.add type, params }.
            to change(instance, :to_a).
            to include(expected)
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it { expect(instance.count).to be 0 }

    it { expect(instance).to alias_method(:count).as(:length) }

    it { expect(instance).to alias_method(:count).as(:size) }

    wrap_context 'when there are many errors' do
      it { expect(instance.count).to be == errors.count }
    end # wrap_context

    wrap_context 'when there are many nested errors' do
      let(:expected) do
        nested_errors.reduce(0) { |memo, (_, hsh)| memo + hsh.size }
      end # let

      it { expect(instance.count).to be == expected }
    end # wrap_context
  end # describe

  describe '#delete' do
    let(:key)  { :title }
    let(:type) { :custom_error }

    it { expect(instance).to respond_to(:delete).with(1).arguments }

    it 'should return an errors proxy' do
      proxy = instance.delete(key)

      expect(proxy).to be_a described_class
      expect(proxy.send :path).to be == []
    end # it

    it 'should not reference the inner data structure' do
      proxy = instance.delete(key)

      expect { proxy.add type }.not_to change(instance, :to_a)
    end # it

    wrap_context 'when there are many nested errors' do
      let(:key) { :articles }

      it 'should return an errors proxy' do
        proxy = instance.delete(key)

        expect(proxy).to be_a described_class
        expect(proxy.send :path).to be == []
      end # it

      it 'should not reference the inner data structure' do
        proxy = instance.delete(key)

        expect { proxy.add type }.not_to change(instance, :to_a)
      end # it

      it 'should remove the referenced data' do
        expect { instance.delete(key) }.to change(instance, :count).to be 1
      end # it
    end # wrap_context
  end # describe

  describe '#dig' do
    let(:key)    { :title }
    let(:type)   { :custom_error }
    let(:params) { {} }
    let(:expected) do
      {
        :type   => type,
        :params => params,
        :path   => path + [key]
      } # end error
    end # let

    it { expect(instance).to respond_to(:dig).with_unlimited_arguments }

    it 'should return an errors proxy' do
      proxy = instance.dig key

      expect(proxy).to be_a described_class
      expect(proxy.send :path).to be == path + [key]
    end # it

    it 'should reference the inner data structure' do
      expect { instance.dig(key).add type }.
        to change(instance, :to_a).
        to include(expected)
    end # it

    describe 'with many keys' do
      let(:keys) { %i(properties location latitude) }
      let(:expected) do
        {
          :type   => type,
          :params => params,
          :path   => path + keys
        } # end error
      end # let

      it 'should reference the inner data structure' do
        expect { instance.dig(*keys).add type }.
          to change(instance, :to_a).
          to include(expected)
      end # it
    end # describe

    wrap_context 'when the path has many ancestors' do
      it 'should return an errors proxy' do
        proxy = instance.dig key

        expect(proxy).to be_a described_class
        expect(proxy.send :path).to be == path + [key]
      end # it

      it 'should reference the inner data structure' do
        expect { instance.dig(key).add type }.
          to change(instance, :to_a).
          to include(expected)
      end # it

      describe 'with many keys' do
        let(:keys) { %i(properties location latitude) }
        let(:expected) do
          {
            :type   => type,
            :params => params,
            :path   => path + keys
          } # end error
        end # let

        it 'should reference the inner data structure' do
          expect { instance.dig(*keys).add type }.
            to change(instance, :to_a).
            to include(expected)
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#each' do
    it { expect(instance).to respond_to(:each).with(0).arguments }

    it 'should return an enumerator' do
      enumerator = instance.each
      yielded    = []

      expect(instance.each).to be_a Enumerator

      enumerator.each { |error| yielded << error }

      expect(yielded).to be == []
    end # it

    it 'should yield each error' do
      yielded = []

      instance.each { |error| yielded << error }

      expect(yielded).to be == []
    end # it

    wrap_context 'when there are many errors' do
      let(:expected) do
        errors.map do |type, params|
          {
            :type   => type,
            :params => params,
            :path   => path
          } # end error
        end # map
      end # let

      it 'should return an enumerator' do
        enumerator = instance.each
        yielded    = []

        expect(instance.each).to be_a Enumerator

        enumerator.each { |error| yielded << error }

        expect(yielded).to be == expected
      end # it

      it 'should yield each error' do
        yielded = []

        instance.each { |error| yielded << error }

        expect(yielded).to be == expected
      end # it

      wrap_context 'when the path has many ancestors' do
        it 'should return an enumerator' do
          enumerator = instance.each
          yielded    = []

          expect(instance.each).to be_a Enumerator

          enumerator.each { |error| yielded << error }

          expect(yielded).to be == expected
        end # it

        it 'should yield each error' do
          yielded = []

          instance.each { |error| yielded << error }

          expect(yielded).to be == expected
        end # it
      end # wrap_context
    end # wrap_context

    wrap_context 'when there are many nested errors' do
      let(:expected) do
        nested_errors.each.with_object([]) do |(relative_path, errors), ary|
          errors.each do |type, params|
            ary << {
              :type   => type,
              :params => params,
              :path   => path + relative_path
            } # end error
          end # each
        end # each
      end # let

      it 'should return an enumerator' do
        enumerator = instance.each
        yielded    = []

        expect(instance.each).to be_a Enumerator

        enumerator.each { |error| yielded << error }

        expect(yielded).to be == expected
      end # it

      it 'should yield each error' do
        yielded = []

        instance.each { |error| yielded << error }

        expect(yielded).to be == expected
      end # it

      wrap_context 'when the path has many ancestors' do
        it 'should return an enumerator' do
          enumerator = instance.each
          yielded    = []

          expect(instance.each).to be_a Enumerator

          enumerator.each { |error| yielded << error }

          expect(yielded).to be == expected
        end # it

        it 'should yield each error' do
          yielded = []

          instance.each { |error| yielded << error }

          expect(yielded).to be == expected
        end # it
      end # wrap_context
    end # wrap_context
  end # describe

  describe '#empty?' do
    it { expect(instance).to have_predicate(:empty?).with_value(true) }

    wrap_context 'when there are many errors' do
      it { expect(instance.empty?).to be false }
    end # wrap_context

    wrap_context 'when there are many nested errors' do
      it { expect(instance.empty?).to be false }
    end # wrap_context
  end # describe

  describe '#include?' do
    let(:type) { :must_be_greater_than }

    it { expect(instance).to respond_to(:include?).with(1).argument }

    describe 'with an error type' do
      it { expect(instance.include? type).to be false }
    end # describe

    describe 'with an error hash' do
      it { expect(instance.include? :type => type).to be false }
    end # describe

    wrap_context 'when there are many errors' do
      describe 'with a non-matching error type' do
        it { expect(instance.include? :divide_by_zero).to be false }
      end # describe

      describe 'with a matching error type' do
        it { expect(instance.include? type).to be true }
      end # describe

      describe 'with a non-matching error hash' do
        let(:expected) do
          { :type => type, :params => { :value => Float::INFINITY } }
        end # let

        it { expect(instance.include? expected).to be false }
      end # describe

      describe 'with a matching error hash' do
        let(:expected) do
          { :type => type, :params => { :value => 0 } }
        end # let

        it { expect(instance.include? expected).to be true }
      end # describe
    end # wrap_context

    wrap_context 'when there are many nested errors' do
      describe 'with a non-matching error type' do
        it { expect(instance.include? :divide_by_zero).to be false }
      end # describe

      describe 'with a matching error type' do
        it { expect(instance.include? type).to be true }
      end # describe

      describe 'with a non-matching error hash' do
        let(:expected) do
          { :type => type, :params => { :value => Float::INFINITY } }
        end # let

        it { expect(instance.include? expected).to be false }
      end # describe

      describe 'with a matching error hash' do
        let(:expected) do
          { :type => type, :params => { :value => 0 } }
        end # let

        it { expect(instance.include? expected).to be true }
      end # describe

      describe 'with a matching error hash with non-matching path' do
        let(:expected) do
          { :type => type, :params => { :value => 0 }, :path => [] }
        end # let

        it { expect(instance.include? expected).to be false }
      end # describe

      describe 'with a matching error hash with non-matching path' do
        let(:expected) do
          {
            :type   => type,
            :params => { :value => 0 },
            :path   => [:articles, 0, :id]
          } # end expected
        end # let

        it { expect(instance.include? expected).to be true }
      end # describe
    end # wrap_context
  end # describe

  describe '#key?' do
    it { expect(instance).to respond_to(:key?).with(1).argument }

    it { expect(instance).to alias_method(:key?).as(:has_key?) }

    it { expect(instance.key? :articles).to be false }

    wrap_context 'when there are many errors' do
      it { expect(instance.key? :articles).to be false }
    end # wrap_context

    wrap_context 'when there are many nested errors' do
      it { expect(instance.key? :articles).to be true }

      it { expect(instance.key? :books).to be false }

      describe 'with an integer' do
        it { expect(instance[:articles].key? 1).to be true }

        it { expect(instance[:articles].key? 2).to be false }
      end # describe

      describe 'with a string' do
        it { expect(instance.key? 'articles').to be true }

        it { expect(instance.key? 'books').to be false }
      end # describe
    end # wrap_context
  end # describe

  describe '#keys' do
    it { expect(instance).to respond_to(:keys).with(0).arguments }

    it { expect(instance.keys).to be == [] }

    wrap_context 'when there are many errors' do
      it { expect(instance.keys).to be == [] }
    end # wrap_context

    wrap_context 'when there are many nested errors' do
      it { expect(instance.keys).to be == [:articles] }

      it { expect(instance[:articles].keys).to be == [0, 1] }
    end # wrap_context
  end # describe

  describe '#path' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:path)

      expect(instance).to respond_to(:path, true).with(0).arguments
    end # it

    it { expect(instance.send :path).to be == [] }

    wrap_context 'when the path has many ancestors' do
      it { expect(instance.send :path).to be == path }
    end # wrap_context
  end # describe

  describe '#to_a' do
    let(:errors) { Array.new(3) { double('error') } }

    it { expect(instance).to respond_to(:to_a).with(0).arguments }

    it 'should delegate to #each' do
      allow(instance).to receive(:each).and_return(errors.each)

      expect(instance.to_a).to be == errors
    end # it
  end # describe
end # describe
