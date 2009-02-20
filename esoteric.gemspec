# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{esoteric}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["faultier"]
  s.date = %q{2009-02-21}
  s.description = %q{Esoteric langage compilers and virtual machines}
  s.email = %q{roteshund+github@gmail.com}
  s.executables = ["bf", "dt", "esoc", "tetete", "ws"]
  s.extra_rdoc_files = ["README", "ChangeLog"]
  s.files = ["README", "ChangeLog", "Rakefile", "bin/bf", "bin/dt", "bin/esoc", "bin/tetete", "bin/ws", "spec/esoteric_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "lib/esoteric", "lib/esoteric/brainfuck", "lib/esoteric/brainfuck/parser.rb", "lib/esoteric/brainfuck.rb", "lib/esoteric/dt", "lib/esoteric/dt/parser.rb", "lib/esoteric/dt.rb", "lib/esoteric/easyvm.rb", "lib/esoteric/parser.rb", "lib/esoteric/runner.rb", "lib/esoteric/tetete", "lib/esoteric/tetete/parser.rb", "lib/esoteric/tetete.rb", "lib/esoteric/vm.rb", "lib/esoteric/whitespace", "lib/esoteric/whitespace/parser.rb", "lib/esoteric/whitespace.rb", "lib/esoteric.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://blog.livedoor.jp/faultier/}
  s.rdoc_options = ["--title", "esoteric documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Esoteric langage compilers and virtual machines}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ruby2ruby>, [">= 1.2.2"])
    else
      s.add_dependency(%q<ruby2ruby>, [">= 1.2.2"])
    end
  else
    s.add_dependency(%q<ruby2ruby>, [">= 1.2.2"])
  end
end
