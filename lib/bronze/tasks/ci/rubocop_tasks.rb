# lib/bronze/tasks/ci/rubocop_tasks.rb

require 'rubocop'

module Bronze::Tasks
  # Thor tasks for running in a Continuous Integration environment.
  class Ci
    desc :rubocop, 'Runs a Rubocop code quality report.'
    method_option :quiet,
      :aliases => '-q',
      :desc    => 'Does not write quality report to STDOUT.'
    # Runs RuboCop and returns the summary hash. If the --quiet option is not
    # selected, also prints the quality report to STDOUT using the progress
    # formatter.
    #
    # @return [Hash] The quality summary.
    def rubocop
      ::RuboCop::CLI.new.run(build_rubocop_args)

      output  = File.read(File.join root_dir, 'tmp/ci/rubocop.json')
      results = JSON.parse output

      results['summary']
    end # method rubocop

    private

    def build_rubocop_args
      args = []

      args << '--format' << 'progress' unless options[:quiet]
      args << '--format' << 'json' << '--out' << 'tmp/ci/rubocop.json'
    end # method build_rspec_args
  end # class
end # module
