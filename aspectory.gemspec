# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aspectory}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2008-11-12}
  s.email = %q{patnakajima@gmail.com}
  s.files = [
    "lib/aspectory",
    "lib/aspectory.rb",
    "lib/aspectory/hook.rb",
    "lib/aspectory/callbacker.rb",
    "lib/aspectory/introspector.rb",
    "lib/aspectory/observed_method.rb",
    "lib/core_ext",
    "lib/core_ext/array.rb",
    "lib/core_ext/method.rb"
  ]
  s.homepage = %q{http://github.com/nakajima/aspectory}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Callbacks for your Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nakajima-nakajima>, [">= 0"])
    else
      s.add_dependency(%q<nakajima-nakajima>, [">= 0"])
    end
  else
    s.add_dependency(%q<nakajima-nakajima>, [">= 0"])
  end
end
