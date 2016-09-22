# vendor/rspec/sleeping_king_studios/concerns/mock_constants.rb

require 'rspec/sleeping_king_studios/concerns'

module RSpec::SleepingKingStudios::Concerns
  module MockConstants
    def mock_class namespace, constant_name, options = {}, &block
      mock_constant namespace, constant_name, options do
        base_class = options.fetch(:base_class, Object)
        base_class = base_class.is_a?(Class) ?
          base_class :
          Object.const_get(base_class.to_s)

        Class.new(base_class).tap do |c|
          instance_exec(c, &block) if block
        end # tap
      end # mock_constant
    end # method mock_class

    def mock_constant namespace, constant_name, options = {}, &block
      scope = options.fetch(:scope, :example)

      around(scope) do |example|
        begin
          mod = namespace.is_a?(Module) ?
            namespace :
            Object.const_get(namespace.to_s)

          mod.const_set constant_name, instance_exec(&block)

          example.call
        ensure
          if mod.const_defined?(constant_name)
            mod.send :remove_const, constant_name
          end # if
        end # begin-ensure
      end # around scope
    end # method mock_constant

    def mock_module namespace, constant_name, options = {}, &block
      mock_constant namespace, constant_name, options do
        Module.new.tap { |m| instance_exec(m, &block) if block }
      end # mock_constant
    end # method mock_module
  end # module
end # module
