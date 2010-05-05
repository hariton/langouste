# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{langouste}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hariton Mizgir"]
  s.date = %q{2010-05-05}
  s.default_executable = %q{translate}
  s.email = %q{hmizgir@gmail.com}
  s.executables = ["translate"]
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
     "bin/translate",
     "config/langouste.yaml",
     "langouste.gemspec",
     "lib/langouste.rb",
     "test/helper.rb",
     "test/test_langouste.rb"
  ]
  s.homepage = %q{http://github.com/hariton/langouste}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Console tool for translation through various online services (google translate, babelfish, pereklad, etc)}
  s.test_files = [
    "test/test_langouste.rb",
     "test/helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mechanize>, [">= 1.0.0"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<mechanize>, [">= 1.0.0"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<mechanize>, [">= 1.0.0"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

