# lib/bronze/thor/ci/rspec_helper.rb

require 'rspec'

require 'bronze/thor/ci'
require 'bronze/thor/task'

module Bronze::Thor::Ci
  # Common helper methods for RSpec-based tasks.
  module RSpecHelper
    def root_dir
      ENV['ROOT_DIR'] || Bronze.gem_path
    end # method root_dir

    def spec_dir
      @spec_dir = File.join root_dir, 'spec'
    end # method spec_dir

    def spec_files
      Dir[File.join spec_dir, '**', '*_spec.rb']
    end # method require_spec_files
  end # module
end # module
