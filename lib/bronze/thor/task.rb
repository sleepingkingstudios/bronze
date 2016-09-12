# lib/bronze/thor/task.rb

require 'thor'

require 'bronze/thor'

module Bronze::Thor
  # Defines one or more Thor tasks with preset configuration.
  module Task
    # Defines helper methods available to any task.
    module Defaults
      private

      def quiet?
        options[:quiet]
      end # method quiet?
    end # module

    def desc task_name, task_description
      @tasks ||= {}

      if @tasks.key?(task_name)
        raise ArgumentError, "task #{task_name.inspect} already defined"
      end # if

      @tasks[task_name] = {
        :description    => task_description,
        :method_options => {}
      } # end hash

      @last_task = task_name
    end # method desc

    def method_option option_name, **options
      raise ArgumentError 'unknown task' unless @last_task

      @tasks[@last_task][:method_options][option_name] = options
    end # method method_option

    private

    def define_tasks other
      @tasks.each do |task_name, task|
        other.send :desc, task_name, task[:description]

        task[:method_options].each do |option_name, options|
          other.send :method_option, option_name, **options
        end # each

        other.send :define_method, task_name do
          super()
        end # method
      end # each
    end # method define_tasks

    def included other
      if other < Thor
        other.define_singleton_method :exit_on_failure?, ->() { true }

        define_tasks(other)

        other.send :include, Defaults
      end # if
    end # method included
  end # module
end # module
