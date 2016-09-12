# bronze.thor

$: << 'lib'

thor_tasks = Dir[File.join __dir__, *%w(lib bronze thor ** *.thor)]

thor_tasks.each { |file_path| Thor::Util.load_thorfile file_path }
