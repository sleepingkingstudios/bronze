# spec/bronze/thor/ci/default_spec.rb

require 'bronze/thor/ci/default'

RSpec.describe Bronze::Thor::Ci::Default do
  let(:described_class) do
    Class.new(::Thor).tap do |klass|
      klass.send :include, super()

      klass.no_commands do
        klass.send :define_method, :rspec,      ->() {}
        klass.send :define_method, :rspec_each, ->() {}
        klass.send :define_method, :rubocop,    ->() {}
      end # no_commands
    end # class
  end # let
  let(:instance) { described_class.new }

  describe '::exit_on_failure?' do
    it 'should define the predicate' do
      expect(described_class).
        to have_predicate(:exit_on_failure?).
        with_value(true)
    end # it
  end # describe

  describe '#default' do
    let(:rspec_results) do
      {
        'example_count' => 10,
        'failure_count' => 0,
        'pending_count' => 0,
        'duration'      => 10.0
      } # end hash
    end # let
    let(:formatted_rspec_results) do
      str = ''
      str << "#{rspec_results['example_count']} examples"
      str << ', ' << "#{rspec_results['failure_count']} failures"
      str << ', ' << "#{rspec_results['pending_count']} pending"
      str << " in #{rspec_results['duration']} seconds."
    end # let
    let(:rspec_each_results) do
      {
        'spec_file_count' => 5,
        'failure_count'   => 0,
        'pending_count'   => 0,
        'total_duration'  => 15.0
      } # end hash
    end # let
    let(:formatted_rspec_each_results) do
      duration = format('%0.2f', rspec_each_results['total_duration'])

      str = ''
      str << "#{rspec_each_results['spec_file_count']} spec files"
      str << ', ' << "#{rspec_each_results['failure_count']} failures"
      str << ', ' << "#{rspec_each_results['pending_count']} pending"
      str << " in #{duration} seconds."
    end # let
    let(:rubocop_results) do
      {
        'inspected_file_count' => 99,
        'offense_count'        => 0
      } # end hash
    end # let
    let(:formatted_rubocop_results) do
      str = ''
      str << "#{rubocop_results['inspected_file_count']} files inspected"
      str << ', ' << "#{rubocop_results['offense_count']} offenses."
    end # let
    let(:simplecov_results) do
      double(
        'results',
        :total_lines   => 100,
        :covered_lines => 95,
        :covered_percent => 95.0
      ) # end double
    end # let

    before(:example) do
      allow(instance).to receive(:rspec).and_return(rspec_results)
      allow(instance).to receive(:rspec_each).and_return(rspec_each_results)
      allow(instance).to receive(:rubocop).and_return(rubocop_results)
      allow(instance).to receive(:simplecov).and_return(simplecov_results)
    end # before example

    it { expect(instance).to respond_to(:default).with(0).arguments }

    it 'should aggregate CI results' do
      expect(instance).to receive(:rspec).
        with(no_args).
        and_return(rspec_results)

      expect(instance).to receive(:rspec_each).
        with(no_args).
        and_return(rspec_each_results)

      expect(instance).to receive(:rubocop).
        with(no_args).
        and_return(rubocop_results)

      expect(instance).to receive(:puts) do |output|
        expect(output).to include(formatted_rspec_results)
        expect(output).to include(formatted_rspec_each_results)
        expect(output).to include(formatted_rubocop_results)
      end # receive

      instance.default
    end # it

    context 'when there are failing RSpec results' do
      let(:rspec_results) { super().merge 'failure_count' => 2 }

      it 'should aggregate CI results' do
        expect(instance).to receive(:rspec).
          with(no_args).
          and_return(rspec_results)

        expect(instance).to receive(:puts) do |output|
          expect(output).to include(formatted_rspec_results)
        end # receive

        expect { instance.default }.
          to raise_error Thor::Error,
            'The following steps failed - rspec'
      end # it
    end # context

    context 'when there are failing RuboCop results' do
      let(:rubocop_results) { super().merge 'offense_count' => 2 }

      it 'should aggregate CI results' do
        expect(instance).to receive(:rubocop).
          with(no_args).
          and_return(rubocop_results)

        expect(instance).to receive(:puts) do |output|
          expect(output).to include(formatted_rubocop_results)
        end # receive

        expect { instance.default }.
          to raise_error Thor::Error,
            'The following steps failed - rubocop'
      end # it
    end # context
  end # describe
end # describe
