# spec/bronze/errors/errors_spec.rb

require 'bronze/errors/errors'

RSpec.describe Bronze::Errors::Errors do
  shared_context 'when many errors are added' do
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

  shared_context 'when there are many ancestors' do
    let(:nesting) { [:articles, 0, :tags] }
  end # shared_context

  shared_context 'when there are many descendants' do
    let(:children) do
      {
        :_        => { :unable_to_connect_to_server => {} },
        :articles => {
          :_ => { :must_be_published => {} },
          0  => {
            :id => {
              :_ => {
                :must_be_numeric                  => {},
                :must_be_an_integer               => {},
                :must_be_greater_than_or_equal_to => { :value => 0 }
              }, # end hash
            }, # end hash
            :tags => {
              :_ => { :must_be_present => {} }
            }, # end hash
          }, # end hash
          1  => {},
          2  => {
            :tags => {
              0 => {
                :name => {
                  :_ => { :already_exists => { :value => 'Favorite Color' } }
                } # end hash
              } # end hash
            } # end hash
          } # end hash
        }, # end hash
        :publisher => {
          :printing_press => {
            :_ => { :must_be_present => {} }
          } # end hash
        } # end hash
      } # end hash
    end # let

    def add_errors errors, hsh
      hsh = hsh.dup

      (hsh.delete(:_) || {}).each do |type, params|
        errors.add(type, **params)
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

  describe '#==' do
    # rubocop:disable Style/NilComparison
    describe 'with nil' do
      it { expect(instance == nil).to be false }
    end # describe
    # rubocop:enable Style/NilComparison

    describe 'with an object' do
      it { expect(instance == Object.new).to be false }
    end # describe

    describe 'with an empty errors object' do
      it { expect(instance == described_class.new).to be true }
    end # describe

    describe 'with an errors object with different errors' do
      let(:other) do
        described_class.new.tap do |other|
          other.add :require_more_minerals
          other.add :require_more_vespene_gas
        end # tap
      end # let

      it { expect(instance == other).to be false }
    end # describe

    wrap_context 'when many errors are added' do
      describe 'with an empty errors object' do
        it { expect(instance == described_class.new).to be false }
      end # describe

      describe 'with an errors object with different errors' do
        let(:other) do
          described_class.new.tap do |other|
            other.add :require_more_minerals
            other.add :require_more_vespene_gas
          end # tap
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an errors object with matching errors' do
        let(:other) do
          described_class.new.tap do |other|
            errors.each do |error_type, error_params|
              other.add error_type, **error_params
            end # each
          end # tap
        end # let

        it { expect(instance == other).to be true }
      end # describe
    end # describe

    wrap_context 'when there are many descendants' do
      describe 'with an empty errors object' do
        it { expect(instance == described_class.new).to be false }
      end # describe

      describe 'with an errors object with different errors' do
        let(:other) do
          described_class.new.tap do |other|
            other.add :require_more_minerals
            other.add :require_more_vespene_gas
          end # tap
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an errors object with matching errors' do
        let(:other) do
          described_class.new.tap do |other|
            children[:_].each do |error_type, error_params|
              other.add error_type, *error_params
            end # each
          end # tap
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an errors object with matching errors and descendants' do
        let(:other) do
          described_class.new.tap do |other|
            add_errors(other, children)
          end # tap
        end # let

        it { expect(instance == other).to be true }
      end # describe
    end # wrap_context
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
      it { expect(instance.add error_type, **error_params).to be instance }

      it 'should append an error' do
        expect { instance.add error_type, **error_params }.
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
    let(:error_params) { {} }

    it 'should define the method' do
      expect(instance).
        to respond_to(:add).
        with(1).argument.
        and_arbitrary_keywords
    end # it

    describe 'with an error type' do
      let(:error_type) { :must_be_present }

      include_examples 'should append an error'
    end # describe

    describe 'with an error type and params' do
      let(:error_type)   { :must_be_between }
      let(:error_params) { { :values => [0, 1] } }

      include_examples 'should append an error'
    end # describe

    wrap_context 'when there are many ancestors' do
      describe 'with an error type' do
        let(:error_type) { :must_be_present }

        include_examples 'should append an error'
      end # describe
    end # wrap_context
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it { expect(instance.count).to be == 0 }

    wrap_context 'when many errors are added' do
      it { expect(instance.count).to be == instance.to_a.size }
    end # wrap_context

    wrap_context 'when there are many descendants' do
      it { expect(instance.count).to be == instance.to_a.size }
    end # wrap_context
  end # describe

  describe '#detect' do
    let(:error) { Bronze::Errors::Error.new [], :require_more_minerals, [] }

    it { expect(instance).to respond_to(:detect).with(0).argument.and_a_block }

    it { expect(instance.detect { |e| e == error }).to be false }

    wrap_context 'when many errors are added' do
      it { expect(instance.detect { |e| e == error }).to be false }

      describe 'with a matching error' do
        let(:error) { Bronze::Errors::Error.new [], *errors.first }

        it { expect(instance.detect { |e| e == error }).to be true }
      end # describe
    end # wrap_context

    wrap_context 'when there are many descendants' do
      it { expect(instance.detect { |e| e == error }).to be false }

      describe 'with a matching error' do
        let(:error) { Bronze::Errors::Error.new [], *children[:_].first }

        it { expect(instance.detect { |e| e == error }).to be true }
      end # describe

      describe 'with a nested matching error' do
        let(:error_nesting) { [:articles, 0, :tags] }
        let(:error) do
          error_data =
            error_nesting.reduce(children) { |hsh, key| hsh[key] }[:_]

          Bronze::Errors::Error.new error_nesting, *error_data.first
        end # let

        it { expect(instance.detect { |e| e == error }).to be true }
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

  describe '#empty?' do
    it { expect(instance).to respond_to(:empty?).with(0).arguments }

    it { expect(instance.empty?).to be true }

    wrap_context 'when many errors are added' do
      it { expect(instance.empty?).to be false }
    end # wrap_context

    wrap_context 'when there are many descendants' do
      it { expect(instance.empty?).to be false }

      context 'when there are no errors on the errors object' do
        let(:children) do
          super().tap { |hsh| hsh.delete :_ }
        end # let

        it { expect(instance.empty?).to be false }
      end # context
    end # wrap_context
  end # describe

  describe '#include?' do
    let(:error) { Bronze::Errors::Error.new [], :require_more_minerals, [] }

    it { expect(instance).to respond_to(:include?).with(1).argument }

    it { expect(instance.include? error).to be false }

    wrap_context 'when many errors are added' do
      it { expect(instance.include? error).to be false }

      describe 'with a matching error' do
        let(:error) { Bronze::Errors::Error.new [], *errors.first }

        it { expect(instance.include? error).to be true }
      end # describe
    end # wrap_context

    wrap_context 'when there are many descendants' do
      it { expect(instance.include? error).to be false }

      describe 'with a matching error' do
        let(:error) { Bronze::Errors::Error.new [], *children[:_].first }

        it { expect(instance.include? error).to be true }
      end # describe

      describe 'with a nested matching error' do
        let(:error_nesting) { [:articles, 0, :tags] }
        let(:error) do
          error_data =
            error_nesting.reduce(children) { |hsh, key| hsh[key] }[:_]

          Bronze::Errors::Error.new error_nesting, *error_data.first
        end # let

        it { expect(instance.include? error).to be true }
      end # describe
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

  describe '#update' do
    shared_examples 'should update the errors' do
      describe 'with an empty errors object' do
        let(:other) { described_class.new }

        it 'should not change the errors' do
          expect { instance.update other }.not_to change(instance, :to_a)

          expected.each do |error_type, error_params|
            expect(instance.to_a).to include { |error|
              error.type == error_type &&
                error.params == error_params &&
                error.nesting == nesting
            } # end include
          end # each
        end # it
      end # describe

      describe 'with an errors object with many errors' do
        let(:other) do
          described_class.new.tap do |other|
            other.add :require_more_minerals
            other.add :require_more_vespene_gas
          end # tap
        end # let

        it 'should add the errors' do
          instance.update other

          expected.each do |error_type, error_params|
            expect(instance.to_a).to include { |error|
              error.type == error_type &&
                error.params == error_params &&
                error.nesting == nesting
            } # end include
          end # each

          # byebug

          expect(instance.to_a).to include { |error|
            error.type == :require_more_minerals &&
              error.nesting == nesting
          } # end include

          expect(instance.to_a).to include { |error|
            error.type == :require_more_vespene_gas &&
              error.nesting == nesting
          } # end include
        end # it
      end # describe

      describe 'with an errors object with nested errors' do
        let(:other) do
          described_class.new.tap do |other|
            other.add :supply_limit_exceeded
            other[:zerg].add :must_spawn_more_overlords
            other[:zerg][:units].add :research_overseers_at_the_hive
          end # tap
        end # let

        it 'should add the errors' do
          instance.update other

          expected.each do |error_type, error_params|
            expect(instance.to_a).to include { |error|
              error.type == error_type &&
                error.params == error_params &&
                error.nesting == nesting
            } # end include
          end # each

          expect(instance.to_a).to include { |error|
            error.type == :supply_limit_exceeded &&
              error.nesting == nesting
          } # end include

          expect(instance.to_a).to include { |error|
            error.type == :must_spawn_more_overlords &&
              error.nesting == nesting + [:zerg]
          } # end include

          expect(instance.to_a).to include { |error|
            error.type == :research_overseers_at_the_hive &&
              error.nesting == nesting + [:zerg, :units]
          } # end include
        end # it
      end # describe
    end # shared_examples

    let(:nesting)  { [] }
    let(:expected) { [] }

    it { expect(instance).to respond_to(:update).with(1).argument }

    include_examples 'should update the errors'

    wrap_context 'when there are many ancestors' do
      include_examples 'should update the errors'
    end # wrap_context

    wrap_context 'when many errors are added' do
      let(:expected) { errors }

      include_examples 'should update the errors'
    end # wrap_context
  end # describe
end # describe
