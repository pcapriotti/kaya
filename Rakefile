require 'rake/testtask'
Rake::TestTask.new do |t|
    require 'test/unit'
    
    t.libs << 'main'
    t.test_files = FileList['test/**/*test.rb']
    t.verbose = true
end

