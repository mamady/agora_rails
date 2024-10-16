Gem::Specification.new do |spec|
  spec.name          = "agora_rails"
  spec.version       = "1.0.0"
  spec.authors       = ["Mohammad Forouzani"]
  spec.email         = ["mo@usechance.com"]

  spec.summary       = "Ruby interface for Agora.io APIs"
  spec.description   = "Provides functionality for Agora.io token generation, cloud recording, and speech-to-text"
  spec.homepage      = "https://github.com/mamady/agora_rails"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 5.0"
  spec.add_dependency "httparty"
  spec.add_dependency "openssl"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
end