Gem::Specification.new do |s|
  s.name = %q{esoteric}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["faultier"]
  s.date = %q{2009-02-17}
  s.description = %q{}
  s.email = %q{roteshund+github@gmail.com}
  s.executables = ["esm", "whitespace", "dt"]
  s.extra_rdoc_files = ["README", "ChangeLog"]
  s.files = ["README", "ChangeLog", "Rakefile", "bin/whitespace", "bin/dt", "bin/esm", "spec/spec_helper.rb", "spec/esoteric_spec.rb", "spec/spec.opts", "lib/esoteric.rb", "lib/esoteric", "lib/esoteric/version.rb", "lib/esoteric/vm.rb", "lib/esoteric/compiler", "lib/esoteric/compiler/dt.rb", "lib/esoteric/compiler/whitespace.rb", "lib/esoteric/compiler.rb", "lib/esoteric/runner.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://blog.livedoor.jp/faultier/}
  s.rdoc_options = ["--title", "esoteric documentation", "--charset", "utf-8", "--opname", "index.html", "--line-numbers", "--main", "README", "--inline-source", "--exclude", "^(examples|extras)/"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
