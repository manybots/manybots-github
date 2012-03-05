module ManybotsGithub
  class Commit < ActiveRecord::Base
    
    belongs_to :repository, :class_name => 'ManybotsGithub::Repository', :foreign_key => 'repository_id'
    has_one :oauth_account, :through => :repository
    has_one :user, :through => :oauth_account 
    
    def commit
      @commit ||= JSON.load(self.payload)
    end
    
    def as_activity
      activity = {
          # PROPERTIES
          :id => "#{ManybotsServer.url}/manybots-github/commits/#{self.id}/activity",
          :url => "#{ManybotsServer.url}/manybots-github/commits/#{self.id}/activity",
          :title => "ACTOR commit to TARGET - #{self.message} (OBJECT)",
          :auto_title => true,
          :summary => self.message,
          :content => self.message,
          :published => self.commit['commit']['author']['date'],
          :icon => {
            :url => 'http://github.com/apple-touch-icon.png'
          },
          :provider => {
            :displayName => 'Github',
            :url => 'https://github.com',
            :image => {
              :url => 'http://github.com/apple-touch-icon.png'
            }
          },
          :generator => {
            :displayName => 'Github Observer',
            :url => "#{ManybotsServer.url}/manybots-github",
            :image => {
              :url => "#{ManybotsServer.url}/assets/manybots-github/icon.png"
            }
          },
          # VERB
          :verb => 'commit',
          # TAGS
          :tags => [self.repository.slug],
          # ACTOR
          :actor => {
            :displayName => self.commit['author']['login'],
            :id => "https://github.com/#{self.commit['author']['login']}",
            :url => "https://github.com/#{self.commit['author']['login']}"
          },
          # OBJECT
          :object => {
            :displayName => self.sha,
            :id => self.repository.repository['html_url'] + "/commit/#{self.sha}",
            :url => self.repository.repository['html_url'] + "/commit/#{self.sha}",
            :objectType => 'commit'
          }
      }

      activity[:target] = {
          :displayName => self.repository.slug,
          :id => self.repository.repository['html_url'],
          :url => self.repository.repository['html_url'],
          :objectType => 'repository',
          :manybots_search => true
        }
      
      activity    
    end
    
    def as_json(options={})
      {:activity => self.as_activity, :version => '1.0'}
    end
    
    def post_to_manybots!
      RestClient.post("#{ManybotsServer.url}/activities.json", 
        {
          :activity => self.as_activity, 
          :client_application_id => ManybotsGithub.app.id,
          :version => '1.0', 
          :auth_token => self.user.authentication_token
        }.to_json, 
        :content_type => :json, 
        :accept => :json
      )
    end    
  end
end
