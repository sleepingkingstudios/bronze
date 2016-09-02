# spec/bronze/errors/errors_spec.rb

require 'bronze/errors/errors'

RSpec.describe Bronze::Errors::Errors do
  shared_context 'when many errors are added' do
    let(:errors) do
      {
        :must_be_present      => [],
        :must_be_numeric      => [],
        :must_be_greater_than => [0]
      } # end hash
    end # let

    before(:example) do
      errors.each do |error_type, error_params|
        instance.add error_type, *error_params
      end # each
    end # before example
  end # shared_context

  shared_context 'when there are many ancestors' do
    let(:nesting) { [:articles, 0, :tags] }
  end # shared_context

  shared_context 'when there are many descendants' do
    let(:children) do
      {
        :_        => { :unable_to_connect_to_server => [] },
        :articles => {
          :_ => { :must_be_published => [] },
          0  => {
            :id => {
              :_ => {
                :must_be_numeric                  => [],
                :must_be_an_integer               => [],
                :must_be_greater_than_or_equal_to => [0]
              }, # end hash
            }, # end hash
            :tags => {
              :_ => { :must_be_present => [] }
            }, # end hash
          }, # end hash
          1  => {},
          2  => {
            :tags => {
              0 => {
                :name => {
                  :_ => { :already_exists => ['Favorite Color'] }
                } # end hash
              } # end hash
            } # end hash
          } # end hash
        }, # end hash
        :publisher => {
          :printing_press => {
            :_ => { :must_be_present => [] }
          } # end hash
        } # end hash
      } # end hash
    end # let
    let(:errors) do
      { :unable_to_connect_to_server => [] }
    end # let

    def add_errors errors, hsh
      hsh = hsh.dup

      (hsh.delete(:_) || {}).each do |type, params|
        errors.add(type, *params)
      end # each

      hsh.each do |key, children|
        child = errors[key]

        add_errors(child, children)
      end # each
    end # method add_errors

    def flatten_errors hsh, nesting = []
      ary = []
      hsh = hsh.dup

      (hsh.delete(:_) || {}).each do |type, params|
        ary << [nesting, type, params]
      end # each

      hsh.each do |key, children|
        ary.concat(flatten_errors children, nesting + [key])
      end # each

      ary
    end # method flatten_errors

    before(:example) { add_errors(instance, children) }
  end # shared_context

  let(:nesting)  { [] }
  let(:instance) { described_class.new nesting }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '#[]' do
    shared_examples 'should return a nested errors object' do
      it 'should return a nested errors object' do
        child = instance[child_name]

        expect(child).to be_a described_class
        expect(child.nesting).to be == (nesting + [child_name])

        expect(child.send :parent).to be instance
      end # it
    end # shared_examples

    let(:child_name) { :id }

    it { expect(instance).to respond_to(:[]).with(1).argument }

    include_examples 'should return a nested errors object'

    wrap_context 'when there are many ancestors' do
      include_examples 'should return a nested errors object'
    end # wrap_context

    wrap_context 'when there are many descendants' do
      let(:child_name) { :articles }
      let(:expected)   { flatten_errors children[:articles], [:articles] }

      it 'should return the existing errors object' do
        child = instance[child_name]

        expect(child).to be_a described_class
        expect(child.nesting).to be == (nesting + [child_name])

        expect(child.send :parent).to be instance

        ary = child.to_a
        ary = ary.map do |error|
          [error.nesting, error.type, error.params]
        end # ary

        expect(ary).to contain_exactly(*expected)
      end # it
    end # wrap_context
  end # describe

  describe '#add' do
    shared_examples 'should append an error' do
      it 'should append an error' do
        expect { instance.add error_type, *error_params }.
          to change { instance.to_a.count }.
          by 1

        error = instance.to_a.last
        expect(error).to be_a Bronze::Errors::Error
        expect(error.nesting).to be == nesting
        expect(error.type).to be error_type
        expect(error.params).to be == error_params
      end # it
    end # shared_examples

    let(:error_type)   { :must_be_present }
    let(:error_params) { [] }

    it 'should define the method' do
      expect(instance).
        to respond_to(:add).
        with(1).argument.
        and_unlimited_arguments
    end # it

    describe 'with an error type' do
      let(:error_type) { :must_be_present }

      include_examples 'should append an error'
    end # describe

    describe 'with an error type and params' do
      let(:error_type)   { :must_be_between }
      let(:error_params) { [0, 1] }

      include_examples 'should append an error'
    end # describe

    wrap_context 'when there are many ancestors' do
      describe 'with an error type' do
        let(:error_type) { :must_be_present }

        include_examples 'should append an error'
      end # describe
    end # wrap_context
  end # describe

  describe '#each' do
    it { expect(instance).to respond_to(:each).with(0).arguments.and_a_block }

    wrap_context 'when many errors are added' do
      it 'should yield the errors' do
        ary = []

        instance.each { |error| ary << error }

        expect(ary.map(&:type)).to contain_exactly(*errors.keys)
        ary.each do |error|
          expect(error.params).to be == errors[error.type]
        end # each
      end # it
    end # wrap_context

    wrap_context 'when there are many descendants' do
      let(:expected) { flatten_errors children }

      it 'should yield the errors' do
        ary = []

        instance.each { |error| ary << error }

        ary = ary.map do |error|
          [error.nesting, error.type, error.params]
        end # ary

        expect(ary).to contain_exactly(*expected)
      end # it
    end # wrap_context
  end # describe

  describe '#map' do
    it { expect(instance).to respond_to(:map).with(0).arguments.and_a_block }

    wrap_context 'when many errors are added' do
      it 'should yield the errors' do
        ary = instance.map { |error| error }

        expect(ary.map(&:type)).to contain_exactly(*errors.keys)
        ary.each do |error|
          expect(error.params).to be == errors[error.type]
        end # each
      end # it
    end # wrap_context

    wrap_context 'when there are many descendants' do
      let(:expected) { flatten_errors children }

      it 'should yield the errors' do
        ary = instance.map { |error| error }

        ary = ary.map do |error|
          [error.nesting, error.type, error.params]
        end # ary

        expect(ary).to contain_exactly(*expected)
      end # it
    end # wrap_context
  end # describe

  describe '#nesting' do
    include_examples 'should have reader', :nesting, []

    wrap_context 'when there are many ancestors' do
      it { expect(instance.nesting).to be == nesting }
    end # wrap_context
  end # describe

  describe '#parent' do
    it { expect(instance).to respond_to(:parent, true).with(0).arguments }

    it { expect(instance.send :parent).to be nil }
  end # describe

  describe '#to_a' do
    it { expect(instance).to respond_to(:to_a).with(0).arguments }

    it { expect(instance.to_a).to be == [] }

    wrap_context 'when many errors are added' do
      it 'should return the errors' do
        ary = instance.to_a
        expect(ary.map(&:type)).to contain_exactly(*errors.keys)
        ary.each do |error|
          expect(error.params).to be == errors[error.type]
        end # each
      end # it
    end # wrap_context

    wrap_context 'when there are many descendants' do
      let(:expected) { flatten_errors children }

      it 'should return the errors' do
        ary = instance.to_a
        ary = ary.map do |error|
          [error.nesting, error.type, error.params]
        end # ary

        expect(ary).to contain_exactly(*expected)
      end # it
    end # wrap_context
  end # describe
end # describe
