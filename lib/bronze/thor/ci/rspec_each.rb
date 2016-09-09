# lib/bronze/thor/ci/rspec_each.rb

require 'rspec'

require 'bronze/thor/ci'
require 'bronze/thor/ci/rspec_each_formatter'
require 'bronze/thor/ci/rspec_each_results'
require 'bronze/thor/task'

module Bronze::Thor::Ci
  # Defines a Thor task for running each spec file individually.
  module RSpecEach
    extend Bronze::Thor::Task

    desc :rspec_each, 'Runs each spec file individually.'
    method_option :quiet,
      :aliases => '-q',
      :desc    => 'Does not write test results to STDOUT.'
    # Runs the spec suite and returns the summary hash. If the --quiet option
    # is not selected, also prints the test results to STDOUT using the
    # documentation formatter.
    #
    # @return [Hash] The spec results.
    def rspec_each
      start_time = Time.now

      aggregated_results = Bronze::Thor::Ci::RSpecResults.new

      run_each_spec_file(aggregated_results)

      puts each_formatter.format_results(aggregated_results) unless quiet?

      aggregated_results.to_hash.merge(
        'total_duration' => Time.now - start_time
      ) # end merge
    end # method rspec

    private

    def each_formatter
      @each_formatter ||= RSpecEachFormatter.new
    end # each_formatter

    def run_spec_file file_path
      cmd = ['CI=true', 'rspec', file_path]
      cmd << '--format=json' << '--out=tmp/ci/rspec_each.json'

      `#{cmd.join ' '}`

      JSON.parse File.read(File.join Bronze.gem_path, 'tmp/ci/rspec_each.json')
    end # method run_spec_file

    def run_each_spec_file aggregated_results
      spec_files.each do |file_path|
        print each_formatter.format_file_path(file_path) unless quiet?

        results = run_spec_file(file_path).merge('file_path' => file_path)

        aggregated_results.update(results)

        puts each_formatter.format_file_results(results) unless quiet?
      end # each
    end # method run_each_spec_file

    def spec_dir
      @spec_dir = File.join Bronze.gem_path, 'spec'
    end # method spec_dir

    def spec_files
      Dir[File.join spec_dir, '**', '*_spec.rb']
    end # method require_spec_files
  end # class
end # module
