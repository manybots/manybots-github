$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "manybots-github/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "manybots-github"
  s.version     = ManybotsGithub::VERSION
  s.authors     = ["Alex Solleiro"]
  s.email       = ["alex@webcracy.org"]
  s.homepage    = "https://www.manybots.com"
  s.summary     = "Add a Github Observer to your local Manybots."
  s.description = "Allows you to import your emails from Gmail into your local Manybots."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.1"
  s.add_dependency "oauth2"
  s.add_dependency "octokit"

  s.add_development_dependency "sqlite3"
end
