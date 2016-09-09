# lib/bronze/thor/ci/rspec.thor

require 'rspec'

require 'bronze/thor/ci'
require 'bronze/thor/task'

module Bronze::Thor::Ci
  # Defines a Thor task for running the full RSpec test suite.
  module RSpec
    extend Bronze::Thor::Task

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

      file_path = File.join Bronze.gem_path, 'tmp/ci/rspec.json'
      results   = JSON.parse File.read(file_path)

      results['summary']
    end # method rspec

    private

    def build_rspec_args
      args = spec_files

      args << '--format=documentation' unless quiet?
      args << '--format=json' << '--out=tmp/ci/rspec.json'
    end # method build_rspec_args

    def spec_dir
      @spec_dir = File.join Bronze.gem_path, 'spec'
    end # method spec_dir

    def spec_files
      Dir[File.join spec_dir, '**', '*_spec.rb']
    end # method require_spec_files
  end # class
end # module
