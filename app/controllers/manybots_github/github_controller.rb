module ManybotsGithub
  class GithubController < ApplicationController
    require 'oauth2'
    
    before_filter :authenticate_user!
    layout 'shared/application'
    
    def index
      @githubs = current_user.oauth_accounts.where(:client_application_id => current_app.id)
      @schedules = ManybotsServer.queue.get_schedules
    end
    
    def new
      consumer = get_consumer
      redirect_to consumer.auth_code.authorize_url(:scope => 'user,repo')
    end
    
    def import
      github = current_user.oauth_accounts.find(params[:id])
      
      schedule_name = "import_manybots_github_repositories_#{github.id}"
      schedules = ManybotsServer.queue.get_schedules
      
      message = 'Please try again.'
      
      if schedules and schedules.keys.include?(schedule_name)
        ManybotsServer.queue.remove_schedule schedule_name
        github.status = 'off'
        message = 'Stopped importing.'
      else 
        github.status = 'on'
        message = 'Started importing.'
        
        ManybotsServer.queue.add_schedule schedule_name, {
          :every => '30m',
          :class => "GithubWorker",
          :queue => "observers",
          :args => {oauth_account_id: github.id, type: 'repos'},
          :description => "Update repositories every 30 minutes for OauthAccount ##{github.id}"
        }
        
        ManybotsServer.queue.enqueue(GithubWorker, {oauth_account_id: github.id, type: 'repos'})
      end
      github.save
      
      redirect_to root_path, :notice => message
    end
    
    def callback
      consumer = get_consumer
      token = consumer.auth_code.get_token(params[:code])
      
      profile_params = token.get('https://api.github.com/user').body
      profile = JSON.parse profile_params

      github = current_user.oauth_accounts.find_or_create_by_client_application_id_and_remote_account_id(current_app.id, profile['login'])
      github.token = token.token
      github.save
      
      redirect_to github_index_path, :notice => "Github account '#{github.remote_account_id}' registered."
    end
    
    
    def destroy
      github = current_user.oauth_accounts.find(params[:id])
      schedule_name = "import_manybots_github_commits_#{github.id}"
      ManybotsServer.queue.remove_schedule schedule_name
      github.destroy
      ManybotsGithub::Commit.where(:oauth_account_id => github.id).destroy_all
      redirect_to github_index_path, :notice => 'Account deleted.'
    end
    
    private
    
    def current_app
      @manybots_github_app ||= ManybotsGithub.app
    end
    
    def get_consumer
      @consumer ||= OAuth2::Client.new(ManybotsGithub.github_app_id, ManybotsGithub.github_app_secret, 
        :site => "https://github.com",
        :authorize_url => "/login/oauth/authorize",
        :token_url => "/login/oauth/access_token"
      )
    end
    
  end
end
