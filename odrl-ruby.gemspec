# frozen_string_literal: true

require_relative "lib/odrl/odrl/version"

Gem::Specification.new do |spec|
  spec.name = "odrl-ruby"
  spec.version = ODRL::ODRL::VERSION
  spec.authors = ["Mark Wilkinson"]
  spec.email = ["markw@illuminae.com"]

  spec.summary = "builds ODRL files."
  spec.description = "A builder for ODRL files. Does basic validation against core ODRL vocabularies. Has a Builder that allows you to create ODRL Profiles to extend the core vocabulary.  DOES NOT validate against a profile.  DOES NOT cover the full ODRL specificaiton, only the bits that I needed!"
  spec.homepage = "https://example.org"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/markwilkinson/ODRL-RUBY"
  spec.metadata["changelog_uri"] = "https://github.com/markwilkinson/ODRL-RUBY/blob/master/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/odrl-ruby/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
