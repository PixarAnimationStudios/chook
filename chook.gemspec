proj_name = 'chook'

require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|
  # General

  s.name        = proj_name
  s.version     = Chook::VERSION
  s.license     = 'Nonstandard'
  s.date        = Time.now.utc.strftime('%Y-%m-%d')
  s.summary     = 'A Ruby framerwork for interaction or handling WebHooks from a Jamf Pro server'
  s.description = <<-EOD
  Details Coming soon
  EOD
  s.authors     = ['Chris Lasell', 'Aurica Hayes']
  s.email       = 'ruby-jss@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  s.files      += Dir['data/**/*']
  s.homepage    = 'http://wiki.pixar.com//'

  # Dependencies

  # http://www.sinatrarb.com/  MIT License (requires 'rack' also MIT)
  s.add_runtime_dependency 'sinatra'

  # https://github.com/stitchfix/immutable-struct MIT (no dependencies)
  s.add_runtime_dependency 'immutable-struct'

  # Rdoc
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.rdoc_options << '--title' << 'Chook' << '--line-numbers' << '--main' << 'README.md'
end
