lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kleos_test/version'

Gem::Specification.new do |spec|
  spec.name          = "kleos_test"
  spec.version       = KleosTest::VERSION
  spec.authors       = ["Akkuzin Maxim"]
  spec.email         = ["akkmaxon2307@gmail.com"]

  spec.summary       = "Test task from kleos.ru"
  spec.description   = "Looking for broken links on kleos.ru"
  spec.homepage      = "https://github.com/makkuzin/kleos_test"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "bin"
  spec.executables   = ["kleos_test"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
