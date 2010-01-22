# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{aspectory}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2010-01-21}
  s.email = %q{patnakajima@gmail.com}
  s.files = ["README.textile", "Rakefile", "lib/aspectory.rb", "lib/aspectory/callbacker.rb", "lib/aspectory/hook.rb", "lib/aspectory/introspector.rb", "lib/aspectory/observed_method.rb", "lib/core_ext/method.rb", "spec/booty_call_spec.rb", "spec/callbacker_spec.rb", "spec/hook_spec.rb", "spec/introspector_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/nakajima/aspectory}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Callbacks for your classes}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

Gemify.last_specification.manifest = %q{auto} if defined?(Gemify)
