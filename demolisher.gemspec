# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{demolisher}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Geoff Garside"]
  s.date = %q{2009-06-09}
  s.email = %q{geoff@geoffgarside.co.uk}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "demolisher.gemspec",
     "lib/demolisher.rb",
     "test/demolisher_test.rb",
     "test/test.xml",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/geoffgarside/demolisher}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Gem for extracting information from XML files, think Builder but backwards}
  s.test_files = [
    "test/demolisher_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 1.1.3"])
    else
      s.add_dependency(%q<libxml-ruby>, [">= 1.1.3"])
    end
  else
    s.add_dependency(%q<libxml-ruby>, [">= 1.1.3"])
  end
end
