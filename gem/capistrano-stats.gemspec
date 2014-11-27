# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano-stats/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-stats"
  gem.version       = Capistrano::Stats::VERSION
  gem.authors       = ["Lee Hambley"]
  gem.email         = ["lee.hambley@gmail.com"]
  gem.description   = %q{Collects anonymous usage statistics about Capistrano to aid with platform support and ruby version targeting.}
  gem.summary       = %q{Official metrics to help the development direction of Capistrano}
  gem.homepage      = "http://metrics.capistranorb.com/"

  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]

  gem.licenses      = ['MIT']

  gem.post_install_message = <<-eos
    Capistrano will ask you the next time you run it if you would like to share
    anonymous usage statistics with the maintainance team to help guide our
    development efforts. We emplore you to opt-in, but we understand if your
    privacy is important to you in this regard.
  eos

end

