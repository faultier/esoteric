# coding: utf-8
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/sshpublisher'
require 'fileutils'
require 'esoteric'
include FileUtils

NAME              = "esoteric"
AUTHOR            = "faultier"
EMAIL             = "roteshund+github@gmail.com"
DESCRIPTION       = "Esoteric langage compilers and virtual machines"
HOMEPATH          = "http://blog.livedoor.jp/faultier/"
BIN_FILES         = %w(bf dt esoc tetete ws)

VERS              = Esoteric::VERSION
REV = File.read(".svn/entries")[/committed-rev="(d+)"/, 1] rescue nil
CLEAN.include ['**/.*.sw?', '*.gem', '.config']
RDOC_OPTS = [
	'--title', "#{NAME} documentation",
	"--charset", "utf-8",
	"--opname", "index.html",
	"--line-numbers",
	"--main", "README",
	"--inline-source",
]

task :default => [:spec]
task :package => [:clean]

spec = Gem::Specification.new do |s|
	s.name              = NAME
	s.version           = VERS
	s.platform          = Gem::Platform::RUBY
	s.has_rdoc          = true
	s.extra_rdoc_files  = ["README", "ChangeLog"]
	s.rdoc_options     += RDOC_OPTS + ['--exclude', '^(examples|extras)/']
	s.summary           = DESCRIPTION
	s.description       = DESCRIPTION
	s.author            = AUTHOR
	s.email             = EMAIL
	s.homepage          = HOMEPATH
	s.executables       = BIN_FILES
	s.bindir            = "bin"
	s.require_path      = "lib"
	#s.autorequire       = ""

  s.add_dependency('ruby2ruby', '>= 1.2.2')

	s.required_ruby_version = '>= 1.8.6'

	s.files = %w(README ChangeLog Rakefile) +
		Dir.glob("{bin,doc,spec,lib,templates,generator,extras,website,script}/**/*") + 
		Dir.glob("ext/**/*.{h,c,rb}") +
		Dir.glob("examples/**/*.rb") +
		Dir.glob("tools/*.rb") +

	s.extensions = FileList["ext/**/extconf.rb"].to_a
end

Rake::GemPackageTask.new(spec) do |p|
	p.need_tar = true
	p.gem_spec = spec
end

task :install do
	name = "#{NAME}-#{VERS}.gem"
	sh %{rake package}
	sh %{sudo gem install pkg/#{name}}
end

task :uninstall => [:clean] do
	sh %{sudo gem uninstall #{NAME}}
end


Rake::RDocTask.new do |rdoc|
	rdoc.rdoc_dir = 'html'
	rdoc.options += RDOC_OPTS
	rdoc.template = "resh"
	#rdoc.template = "#{ENV['template']}.rb" if ENV['template']
	if ENV['DOC_FILES']
		rdoc.rdoc_files.include(ENV['DOC_FILES'].split(/,\s*/))
	else
		rdoc.rdoc_files.include('README', 'ChangeLog')
		rdoc.rdoc_files.include('lib/**/*.rb')
		rdoc.rdoc_files.include('ext/**/*.c')
	end
end

desc 'Show information about the gem.'
task :debug_gem do
	puts spec.to_ruby
end

desc 'Update gem spec'
task :gemspec do
  open("#{NAME}.gemspec", 'w').write spec.to_ruby
end

require 'spec/rake/spectask'

SPEC_DIR = 'spec'
SPEC_OPTS = [
  '--options', "#{SPEC_DIR}/spec.opts",
]
SPEC_FILES = FileList["#{SPEC_DIR}/**/*_spec.rb"]
RCOV_OPTS = [
  '--exclude', 'spec',
]
SPEC_CONTEXT = lambda {|t|
    t.spec_files = SPEC_FILES
    t.spec_opts = SPEC_OPTS
    t.warning = false
    t.libs = %w(lib)
}

desc "Run specs"
Spec::Rake::SpecTask.new { |t| SPEC_CONTEXT.call(t) }

Spec::Rake::SpecTask.new :rcov do |t|
  SPEC_CONTEXT.call(t)
  t.rcov = true
  t.rcov_opts = RCOV_OPTS
end

desc "Run specs using RCov"
task 'spec:rcov' => :rcov

namespace :spec do
  %w(brainfuck dt tetete whitespace).each do |lang|
    desc "Run #{lang} specs"
    Spec::Rake::SpecTask.new lang do |t| 
      SPEC_CONTEXT.call(t)
      t.spec_files = FileList["#{SPEC_DIR}/#{lang}/*_spec.rb"]
    end
  end

  desc "Run all language's parser specs"
  Spec::Rake::SpecTask.new :parser do |t|
    SPEC_CONTEXT.call(t)
    t.spec_files = FileList["#{SPEC_DIR}/**/*_spec.rb"]
  end

  desc 'Run compiler specs'
  Spec::Rake::SpecTask.new :compiler do |t|
    SPEC_CONTEXT.call(t)
    t.spec_files = ["#{SPEC_DIR}/compiler_spec.rb"]
  end
end
