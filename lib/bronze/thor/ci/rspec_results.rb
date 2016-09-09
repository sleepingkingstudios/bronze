# lib/bronze/thor/ci/rspec_results.rb

require 'bronze/thor/ci'

module Bronze::Thor::Ci
  # @api private
  class RSpecResults
    def initialize
      @summary          = Hash.new { |hsh, key| hsh[key] = 0 }
      @profile          = Hash.new { |hsh, key| hsh[key] = 0.0 }
      @failing_examples = []
      @failing_files    = []
    end # constructor

    attr_reader :summary
    attr_reader :profile
    attr_reader :failing_examples
    attr_reader :failing_files

    def example_count
      summary['example_count'].to_i
    end # method example_count

    def failing?
      failure_count > 0
    end # method failing?

    def failure_count
      summary['failure_count'].to_i
    end # method failure_count

    def passing?
      !(failing? && pending?)
    end # method passing?

    def pending?
      !failing? && pending_count > 0
    end # method pending?

    def pending_count
      summary['pending_count'].to_i
    end # method pending_count

    def update results
      update_summary(results)

      profile['total'] += results['profile']['total']

      update_failures(results)
    end # method update

    private

    def update_failures results
      return unless results['summary']['failure_count'].to_i > 0

      failing_files << results['file_path'] if results['file_path']

      examples = results['examples'].select do |example|
        example['status'] == 'failed'
      end # select

      failing_examples.concat(examples)
    end # method update_failures

    def update_summary results
      %w(duration example_count failure_count pending_count).each do |key|
        metric = results['summary'][key]

        summary[key] += metric
      end # each
    end # method update_summary
  end # class
end # module
