# spec/bronze/tasks/ci_spec.rb

load 'bronze/tasks/ci.thor'

require 'rubocop'

RSpec.describe Bronze::Tasks::Ci do
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
        'example_count' => 5,
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
      allow(instance).to receive(:rubocop).and_return(rubocop_results)
      allow(instance).to receive(:simplecov).and_return(simplecov_results)
    end # before example

    it { expect(instance).to respond_to(:default).with(0).arguments }

    it 'should aggregate CI results' do
      expect(instance).to receive(:rspec).
        with(no_args).
        and_return(rspec_results)

      expect(instance).to receive(:rubocop).
        with(no_args).
        and_return(rubocop_results)

      expect(instance).to receive(:puts) do |output|
        expect(output).to include(formatted_rspec_results)
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

  describe '#rspec' do
    let(:root_dir)   { File.expand_path(__dir__).split('/spec').first }
    let(:spec_dir)   { File.join root_dir, 'spec' }
    let(:spec_files) { Dir[File.join spec_dir, '**', '*_spec.rb'] }
    let(:task_options) do
      {}
    end # let
    let(:expected_options) do
      opts = []

      opts << '--format=documentation' unless task_options[:quiet]
      opts << '--format=json' << '--out=tmp/ci/rspec.json'
    end # let
    let(:expected_results) do
      { 'summary' => { 'Greetings' => 'Programs' } }
    end # let

    before(:example) do
      allow(instance).to receive(:options).and_return(task_options)
    end # before

    def mock_files
      allow(File).to receive(:read).
        with(File.join root_dir, 'tmp/ci/rspec.json').
        and_return(JSON.dump expected_results)
    end # method mock_files

    def mock_rspec
      expect(RSpec::Core::Runner).to receive(:run) do |args|
        expect(args).to be == spec_files + expected_options
      end # receive
    end # method mock_rspec

    it { expect(instance).to respond_to(:rspec).with(0).arguments }

    it 'should wrap the RSpec test suite' do
      mock_rspec
      mock_files

      results = instance.rspec

      expect(results).to be == expected_results['summary']
    end # it

    context 'with :quiet => true' do
      let(:task_options) { super().merge :quiet => true }

      it 'should wrap the RSpec test suite' do
        mock_rspec
        mock_files

        results = instance.rspec

        expect(results).to be == expected_results['summary']
      end # it
    end # context
  end # describe

  describe '#rubocop' do
    let(:root_dir) { File.expand_path(__dir__).split('/spec').first }
    let(:task_options) do
      {}
    end # let
    let(:expected_options) do
      opts = []

      opts << '--format' << 'progress' unless task_options[:quiet]
      opts << '--format' << 'json' << '--out' << 'tmp/ci/rubocop.json'
    end # let
    let(:expected_results) do
      { 'summary' => { 'Greetings' => 'Programs' } }
    end # let

    before(:example) do
      allow(instance).to receive(:options).and_return(task_options)
    end # before

    def mock_files
      allow(File).to receive(:read).
        with(File.join root_dir, 'tmp/ci/rubocop.json').
        and_return(JSON.dump expected_results)
    end # method mock_files

    def mock_rubocop
      client = double('cli', :run => nil)

      allow(RuboCop::CLI).to receive(:new).and_return(client)

      expect(client).to receive(:run).with(expected_options)
    end # method mock_rubocop

    it { expect(instance).to respond_to(:rubocop).with(0).arguments }

    it 'should wrap the RuboCop CLI' do
      mock_rubocop
      mock_files

      results = instance.rubocop

      expect(results).to be == expected_results['summary']
    end # it

    context 'with :quiet => true' do
      let(:task_options) { super().merge :quiet => true }

      it 'should wrap the RuboCop CLI' do
        mock_rubocop
        mock_files

        results = instance.rubocop

        expect(results).to be == expected_results['summary']
      end # it
    end # context
  end # describe
end # describe
