class GithubWorker
  @queue = :observers
  
  attr_accessor :client, :github_account_id, :github_account, :github_user, :auto_traversal_for_commits
  
  def initialize(github_account_id, auto_traversal_for_commits=false)
    @github_account_id = github_account_id
    @github_account = OauthAccount.find(@github_account_id)
    @github_user = github_account.remote_account_id
    github_token = github_account.token
    @client = Octokit::Client.new(:login => @github_user, :oauth_token => github_token)
    @auto_traversal_for_commits = auto_traversal_for_commits
    puts "auto_traversal_for_commits is: #{@auto_traversal_for_commits}" 
  end
  
  def fetch_push_events
    @client.auto_traversal = true
    events = @client.user_events @github_user#, :per_page => 100, :page => page
    push_event_key = "PushEvent"
    result = events.group_by(&:type).delete_if {|k,v| k != push_event_key}
    result[push_event_key]
  end
  
  def fetch_all_repos
    @client.auto_traversal = true
    @client.repos
  end
  
  def fetch_all_branches(repo)
    repo_name = repo.is_a?(String) ? repo : "#{repo.owner.login}/#{repo.name}"
    @client.auto_traversal = true
    @client.branches repo_name
  end

  def fetch_all_commits(repo, branch='master')
    repo_name = repo.is_a?(String) ? repo : "#{repo.owner.login}/#{repo.name}"
    branch_name = branch.is_a?(String) ? branch : branch.name
    @client.auto_traversal = @auto_traversal_for_commits
    commits = @client.commits repo_name, branch_name
    # only return commits from the current user
    commits.group_by{|c| c.author.login rescue(nil)}.delete_if{|k,v| k != @github_user}[@github_user]
  end
  
  def import_repos!
    repos = self.fetch_all_repos
    repositories = ManybotsGithub::Repository.select('remote_id, oauth_account_id').where(oauth_account_id: @github_account_id)
    unless repositories.empty?
      repositories = repositories.collect(&:remote_id)
    end
    repos.each do |repo|
      if repositories.empty? or !repositories.include?(repo.id)
        repository = ManybotsGithub::Repository.create! do |repository|
          repository.oauth_account_id = @github_account_id
          repository.remote_id = repo.id
          repository.slug = "#{repo.owner.login}/#{repo.name}"
          repository.payload = repo.to_json
        end
      end
    end
    repositories = ManybotsGithub::Repository.select('id, oauth_account_id').where(oauth_account_id: @github_account_id)
    repositories.each do |repo|
      ManybotsServer.queue.add GithubWorker, oauth_account_id: @github_account_id, type: 'commits', repo: repo.id
    end unless repositories.empty?
  end
  
  def self.perform(options={}, autotraversal=false)
    github_account_id = options.delete('oauth_account_id') || raise("Need an OauthAccount id.")
    what = options.delete('type') || 'repos'
    repo_id = options.delete('repo') || nil
    
    client = GithubWorker.new(github_account_id, autotraversal)
    
    if what == 'repos'
      client.import_repos!
    elsif what == 'commits'
      repo = ManybotsGithub::Repository.find(repo_id)
      branches = client.fetch_all_branches(repo.slug)
      branches.each do |branch|
        commits = repo.commits_from_github(branch.name)
        commits.each do |commit|
          unless ManybotsGithub::Commit.exists?(repository_id: repo.id, sha: commit.sha)
            c = ManybotsGithub::Commit.new
            c.repository_id = repo.id
            c.sha = commit.sha
            c.message = commit.commit.message
            c.payload = commit.to_json
            c.save
            c.post_to_manybots!
          end
        end if commits and commits.any?
      end if branches and branches.any?
    end
  end
  
  
end
