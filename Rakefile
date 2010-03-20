require 'rake/testtask'

namespace :test do
  task :extra do |t|
    test_files = FileList['test-extra/**/test*.rb']
    test_files.each do |file|
      ruby "-Ilib #{file}"
    end
  end
end

Rake::TestTask.new(:test => 'test:extra') do |t|
  t.test_files = FileList['test/**/test*.rb']
  t.verbose = true
end
