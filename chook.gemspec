proj_name = 'chook'

require "./lib/#{proj_name}/version"

Gem::Specification.new do |s|

  # General

  s.name        = proj_name
  s.version     = Chook::VERSION
  s.license     = 'Apache 2.0'
  s.date        = Time.now.utc.strftime("%Y-%m-%d")
  s.summary     = "A Ruby framerwork for interaction or handling WebHooks from a Jamf Pro server"
  s.description = <<-EOD
  Details Coming soon
  EOD
  s.authors     = ["Chris Lasell", "Aurica Hayes"]
  s.email       = 'chrisl@pixar.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://wiki.pixar.com//'

  # Dependencies

  # Rdoc

  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options << '--title' << 'PixPrint' << '--line-numbers' << '--main' << 'README.md'
end
