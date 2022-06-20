
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "merge_attributes/version"

Gem::Specification.new do |spec|
  spec.name          = "merge_attributes"
  spec.version       = MergeAttributes.gem_version
  spec.authors       = ["CookiesHQ"]
  spec.email         = ["developers@cookieshq.co.uk"]

  spec.summary       = %q{Merge hashes as HTML attributes, accounting for the specifics of `class`,`data-controller`, `data-action`}
  spec.homepage      = "https://github.com/cookieshq/merge_attributes"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/cookieshq/merge_attributes"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.1.0"

  spec.add_development_dependency "bundler", ">= 2.0.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec-rails", "~>4.0.0"

  # >= 6.1.0 so it provides the `token_list` helper
  # https://github.com/rails/rails/blob/6e2247e9760da37882429b7a72dff1dd1ea5963e/actionview/lib/action_view/helpers/tag_helper.rb#L341
  spec.add_runtime_dependency "rails", ">=6.1.0"
end
