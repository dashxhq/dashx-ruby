require_relative 'lib/dashx/version'

Gem::Specification.new do |spec|
  spec.name          = 'dashx'
  spec.version       = Dashx::VERSION
  spec.authors       = ['DashX']
  spec.email         = ['gdgulshan.007@gmail.com']

  spec.summary       = %q{DashX Ruby Library}
  # spec.description   = %q{TODO: Write a longer description.}
  spec.homepage      = 'https://dashx.com'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''

  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'TODO: Put your gem's public repo URL here.'
  # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         =   spec.files         = Dir['lib/**/*.rb']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # service gems
  spec.add_dependency('dashx-pigeon')
end
