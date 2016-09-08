# lib/bronze/tasks/ci/rspec_tasks.rb

require 'rspec'

module Bronze::Tasks
  # Thor tasks for running in a Continuous Integration environment.
  class Ci
    desc :rspec, 'Runs the RSpec test suite.'
    method_option :quiet,
      :aliases => '-q',
      :desc    => 'Does not write test results to STDOUT.'

    # Runs the spec suite and returns the summary hash. If the --quiet option
    # is not selected, also prints the test results to STDOUT using the
    # documentation formatter.
    #
    # @return [Hash] The spec results.
    def rspec
      $LOAD_PATH << spec_dir unless $LOAD_PATH.include?(spec_dir)

      require 'spec_helper'

      ::RSpec::Core::Runner.run(build_rspec_args)

      results = JSON.parse File.read(File.join root_dir, 'tmp/ci/rspec.json')

      results['summary']
    end # method rspec

    private

    def build_rspec_args
      args = spec_files

      args << '--format=documentation' unless options[:quiet]
      args << '--format=json' << '--out=tmp/ci/rspec.json'
    end # method build_rspec_args

    def spec_dir
      @spec_dir = File.join root_dir, 'spec'
    end # method spec_dir

    def spec_files
      Dir[File.join spec_dir, '**', '*_spec.rb']
    end # method require_spec_files
  end # class
end # module
