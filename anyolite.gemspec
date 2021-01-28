Gem::Specification.new do |s|
  s.name        = 'anyolite'
  s.version     = '0.1.3'
  s.date        = '2021-01-24'
  s.summary     = "Simplistic web framework"
  s.description = "A simplistic web framework"
  s.authors     = ["André Brás"]
  s.email       = 'andregoncalo.bras@gmail.com'
  s.files       = [
    "lib/anyolite.rb",
    "lib/anyolite/http/status.rb",
    "lib/anyolite/action.rb",
    "lib/anyolite/request.rb",
    "lib/anyolite/response.rb",
    "lib/anyolite/context.rb",
    "lib/anyolite/renderer/template.rb",
    "lib/anyolite/renderer/text.rb",
    "lib/anyolite/renderer/json.rb",
    "lib/anyolite/middleware/context.rb",
  ]
  s.homepage = 'https://github.com/whity/ruby-anyolite'
  s.license  = 'MIT'

  s.add_runtime_dependency 'hanami-router', '~> 1.3', '>= 1.3.2'
end
