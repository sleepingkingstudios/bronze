require 'sleeping_king_studios/tasks'

SleepingKingStudios::Tasks.configure do |config|
  config.ci do |ci|
    # Handle Travis-CI log length limit.
    ci.rspec.update format: 'progress' if ENV['TRAVIS']

    ci.steps =
      if ENV['CI']
        %i[rspec rspec_each rubocop]
      else
        %i[rspec rubocop]
      end
  end

  config.file do |file|
    file.template_paths =
      [
        '../sleeping_king_studios-templates/lib',
        file.class.default_template_path
      ]
  end
end

load 'sleeping_king_studios/tasks/ci/tasks.thor'
load 'sleeping_king_studios/tasks/file/tasks.thor'
