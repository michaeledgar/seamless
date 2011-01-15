require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'seamless'
    gem.summary = %Q{Write ruby without all those 'end's.}
    gem.description = %Q{Python allows you to signal the end of a code block
with indentation. Ruby suffers from an extremely verbose and tedious block
terminator, "end". Much like Lisps end up with dozens of close-parens, Ruby
files that use modules and classes heavily end up with a plethora of "ends"
that just aren't necessary.

Write a Ruby file, but skip all the "ends". Line up your code blocks like in
Python. Then just call it 'your_file.rbe', require 'seamless', and require
'your_file'. Seamless does the rest.}
    gem.email = 'michael.j.edgar@dartmouth.edu'
    gem.homepage = 'http://github.com/michaeledgar/seamless'
    gem.authors = ['Michael Edgar']
    gem.add_dependency 'polyglot', '>= 0.3.1'
    gem.add_dependency 'rubylexer', '>= 0.7.7'
    gem.add_development_dependency 'rspec', '~> 1.2'
    gem.add_development_dependency 'yard', '>= 0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end
  
  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
  end
  task :spec => :check_dependencies
  task :default => :spec
rescue LoadError
  task :spec do
    puts 'RSpec 1.x is required for development. An upgrade to 2.x is coming!'
  end
  task :default => :spec
end


begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
