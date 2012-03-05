module ManybotsGithub
  class Repository < ActiveRecord::Base
    belongs_to :oauth_account
    has_one :user, :through => :oauth_account
    
    def repository
      @repository ||= JSON.load(self.payload)
    end
    
    def commits_from_github(branch='master')
      client = GithubWorker.new(self.oauth_account_id)
      return client.fetch_all_commits(self.slug, branch)
    end
  end
end
