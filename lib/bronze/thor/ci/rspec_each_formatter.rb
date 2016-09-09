# lib/bronze/thor/ci/rspec_each_formatter.rb

require 'bronze/thor/ci'
require 'bronze/thor/formatter'

module Bronze::Thor::Ci
  # @api private
  class RSpecEachFormatter < Bronze::Thor::Formatter
    def format_file_path file_path
      "Running specs at #{file_path.sub("#{root_dir}/", '')}"
    end # methdo format_file_path

    def format_file_results results
      str = ' - '

      str <<
        if results['summary']['failure_count'] > 0
          colorize('FAILED', :red)
        elsif results['summary']['pending_count'] > 0
          colorize('PENDING', :yellow)
        else
          colorize('PASSED', :green)
        end # if-elsif
    end # method format_file_results

    def format_results aggregated_results
      str = "\n"

      if aggregated_results.failing?
        str << format_results_failures(aggregated_results)
      end # if

      fmt        = 'Finished in %0.5f seconds (total %0.5f seconds)'
      spec_time  = aggregated_results.profile['total']
      suite_time = aggregated_results.profile['suite']
      str << format(fmt, spec_time, suite_time) << "\n"

      str << format_results_summary(aggregated_results)

      str << "\n"
    end # method format_results

    private

    def format_results_count aggregated_results
      fmt = '%i examples, %i failures'
      fmt << ', %i pending' if aggregated_results.pending?

      format(
        fmt,
        aggregated_results.example_count,
        aggregated_results.failure_count,
        aggregated_results.pending_count
      ) # end format
    end # method format_results_count

    def format_results_failures aggregated_results
      str = 'Failures:' << "\n" << "\n"

      aggregated_results.failing_files.each do |file_path|
        relative_path = file_path.sub("#{root_dir}/", '')

        str << "    #{colorize relative_path, :red}" << "\n"
      end # each

      str << "\n"
    end # method format_failures

    def format_results_summary aggregated_results
      fmt   = format_results_count(aggregated_results)
      color =
        if aggregated_results.failing?
          :red
        elsif aggregated_results.pending?
          :yellow
        else
          :green
        end # if-elsif-else
      colorize(fmt, color) << "\n"
    end # method format_results_summary

    def root_dir
      @root_dir ||= File.expand_path(__dir__).split('/lib').first
    end # method root_dir
  end # class
end # module
