proj_name = 'chook'

require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|
  # General

  s.name        = proj_name
  s.version     = Chook::VERSION
  s.license     = 'Nonstandard'
  s.date        = Time.now.utc.strftime('%Y-%m-%d')
  s.summary     = 'A Ruby framework for simulating and processing Jamf Pro Webhooks'
  s.description = <<-EOD
  Chook is a Ruby module which implements a framework for working with webhook events
  sent by the JSS, the core of Jamf Pro, a management tool for Apple devices.

  Chook also provides a simple, sinatra-based HTTP server, for handling those Events,
  and classes for sending simulated TestEvents to a webhook handling server.
  EOD
  s.authors     = ['Chris Lasell', 'Aurica Hayes']
  s.email       = 'chook@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  s.files      += Dir['data/**/*']
  s.files      += Dir['bin/**/*']
  s.homepage    = 'https://github.com/PixarAnimationStudios/chook'

  # Dependencies

  # http://www.sinatrarb.com/  MIT License (requires 'rack' also MIT)
  s.add_runtime_dependency 'sinatra', '=1.4.8'

  # Rdoc
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.rdoc_options << '--title' << 'Chook' << '--line-numbers' << '--main' << 'README.md'
end
