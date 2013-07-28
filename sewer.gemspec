# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "sewer"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Godfrey Chan"]
  s.email       = ["godfreykfc@gmail.com"]
  s.homepage    = "https://github.com/vanruby/sewer"
  s.summary     = "Sewer"
  s.description = "An experimental JSON encoder that reuses cached fragments"

  s.required_ruby_version = ">= 2.0.0"
  s.required_rubygems_version = ">= 2.0.0"

  s.add_runtime_dependency 'activesupport', ">= 4.0.0"

  s.files        = Dir.glob("lib/**/*") # + %w(README.md CHANGELOG.md LICENSE)
  s.require_path = 'lib'
end