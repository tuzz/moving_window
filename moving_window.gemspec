Gem::Specification.new do |s|
  s.name        = 'moving_window'
  s.version     = '2.0.5'
  s.summary     = 'Moving Window'
  s.description = 'A helper for building scopes that deal with moving windows.'
  s.author      = 'Chris Patuzzo'
  s.email       = 'chris@patuzzo.co.uk'
  s.homepage    = 'https://github.com/tuzz/moving_window'
  s.files       = ['README.md'] + Dir['lib/**/*.*']

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activerecord', '3.2.22'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
end
