# spec/bronze/thor/ci/rspec_each_spec.rb

require 'bronze/thor/ci/rspec_each'

RSpec.describe Bronze::Thor::Ci::RSpecEach do
  let(:described_class) do
    Class.new(::Thor).tap do |klass|
      klass.send :include, super()
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

  describe '#rspec_each' do
    let(:spec_dir)   { File.join Bronze.gem_path, 'spec' }
    let(:spec_files) { Dir[File.join spec_dir, '**', '*_spec.rb'] }
    let(:task_options) do
      {}
    end # let
    let(:expected_options) do
      opts = []

      opts << '--format=json' << '--out=tmp/ci/rspec.json'
    end # let
    let(:file_results) do
      {
        'summary' => {
          'example_count' => 6,
          'failure_count' => 0,
          'pending_count' => 0,
          'duration'      => 0.01
        },
        'profile'  => { 'total' => 0.02 },
        'examples' => []
      } # end hash
    end # let
    let(:expected_example_count) { 6 * spec_files.count }
    let(:expected_failure_count) { 0 }
    let(:expected_pending_count) { 0 }
    let(:expected_duration)      { 0.01 * spec_files.count }
    let(:captured_output)        { StringIO.new }

    def capture_output
      %i(print puts).each do |method|
        allow(instance).to receive(method) do |*args|
          captured_output.send(method, *args)
        end # allow
      end # each
    end # method capture_output

    before(:example) do
      allow(instance).to receive(:options).and_return(task_options)

      capture_output
    end # before

    it { expect(instance).to respond_to(:rspec_each).with(0).arguments }

    it 'should run each spec file' do
      run_files = []

      allow(instance).to receive(:run_spec_file) do |file_path|
        run_files << file_path

        file_results
      end # method

      results = instance.rspec_each

      expect(results).to be_a Hash
      expect(results['example_count']).to be == expected_example_count
      expect(results['failure_count']).to be == expected_failure_count
      expect(results['pending_count']).to be == expected_pending_count
      expect(results['duration']).to be_within(0.001).of(expected_duration)
    end # it

    context 'when the files have failing examples' do
      let(:file_results) do
        super().tap do |hsh|
          hsh['summary']['failure_count'] = 3
        end # tap
      end # let
      let(:expected_failure_count) { 3 * spec_files.count }

      it 'should run each spec file' do
        run_files = []

        allow(instance).to receive(:run_spec_file) do |file_path|
          run_files << file_path

          file_results
        end # method

        results = instance.rspec_each

        expect(results).to be_a Hash
        expect(results['example_count']).to be == expected_example_count
        expect(results['failure_count']).to be == expected_failure_count
        expect(results['pending_count']).to be == expected_pending_count
        expect(results['duration']).to be_within(0.001).of(expected_duration)
      end # it
    end # context

    context 'when the files have pending examples' do
      let(:file_results) do
        super().tap do |hsh|
          hsh['summary']['pending_count'] = 1
        end # tap
      end # let
      let(:expected_pending_count) { spec_files.count }

      it 'should run each spec file' do
        run_files = []

        allow(instance).to receive(:run_spec_file) do |file_path|
          run_files << file_path

          file_results
        end # method

        results = instance.rspec_each

        expect(results).to be_a Hash
        expect(results['example_count']).to be == expected_example_count
        expect(results['failure_count']).to be == expected_failure_count
        expect(results['pending_count']).to be == expected_pending_count
        expect(results['duration']).to be_within(0.001).of(expected_duration)
      end # it
    end # context
  end # describe

  describe '#run_spec_file' do
    let(:spec_file) { 'directory/example_spec.rb' }
    let(:file_results) do
      {
        'summary' => {
          'example_count' => 6,
          'failure_count' => 0,
          'pending_count' => 0,
          'duration'      => 0.01
        },
        'profile'  => { 'total' => 0.02 },
        'examples' => []
      } # end hash
    end # let
    let(:expected_options) do
      {
        'format' => 'json',
        'out'    => 'tmp/ci/rspec_each.json'
      } # end hash
    end # let

    def mock_files
      allow(File).to receive(:read).
        with(File.join Bronze.gem_path, 'tmp/ci/rspec_each.json').
        and_return(JSON.dump file_results)
    end # method mock_files

    before(:example) { mock_files }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:run_spec_file)

      expect(instance).to respond_to(:run_spec_file, true).with(1).argument
    end # if

    it 'should run a shell command' do
      expect(instance).to receive(:`) do |command|
        fragments = command.split(/\s+/)

        expect(fragments.shift).to be == 'CI=true'
        expect(fragments.shift).to be == 'rspec'
        expect(fragments.shift).to be == spec_file

        options =
          fragments.each.with_object({}) do |fragment, hsh|
            key, value = fragment.split('=')

            hsh[key.sub(/^--/, '')] = value
          end # each

        expect(options).to be == expected_options
      end # expect

      expect(instance.send :run_spec_file, spec_file).to be == file_results
    end # it
  end # describe
end # describe
