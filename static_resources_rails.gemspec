require_relative 'lib/static_resources_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "static_resources_rails"
  spec.version       = StaticResourcesRails::VERSION
  spec.authors       = ["aki77"]
  spec.email         = ["aki77@users.noreply.github.com"]

  spec.summary       = %q{Delivering static resources from s3.}
  spec.description   = %q{Delivering static resources from s3.}
  spec.homepage      = "https://github.com/SonicGarden/static_resources_rails"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "aws-sdk-s3"
  spec.add_dependency "mime-types"
  spec.add_dependency "concurrent-ruby"
end
