# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'omniauth/realme/version'

Gem::Specification.new do |s|
  s.name     = 'omniauth-realme'
  s.version  = OmniAuth::Realme::VERSION
  s.authors  = ['Lewis Carey']
  s.email    = ['lewisc@datacom.co.nz']
  s.summary  = 'RealMe Strategy for OmniAuth'
  s.homepage = 'https://github.com/Datacom/omniauth-realme'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'omniauth', '~> 1.0'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
end
