require "manybots-github/engine"

module ManybotsGithub
  
  # Github App Id for OAuth2
  mattr_accessor :github_app_id
  @@github_app_id = nil

  # Github App Secret for OAuth2
  mattr_accessor :github_app_secret
  @@github_app_secret = nil
  
  mattr_accessor :app
  @@app = nil
  
  mattr_accessor :nickname
  @@nickname = nil
  
  
  def self.setup
    yield self
  end
  
end
