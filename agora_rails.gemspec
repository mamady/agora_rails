Gem::Specification.new do |spec|
  spec.name          = "agora_rails"
  spec.version       = "1.0.1"
  spec.authors       = ["Mohammad Forouzani"]
  spec.email         = ["mo@usechance.com"]

  spec.summary       = "Ruby interface for Agora.io APIs"
  spec.description   = "Provides functionality for Agora.io token generation and cloud recording"
  spec.homepage      = "https://github.com/mamady/agora_rails"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 5"
  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "openssl", "~> 3"

  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "webmock", "~> 3.21"
end