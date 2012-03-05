Rails.application.routes.draw do

  mount ManybotsGithub::Engine => "/manybots-github"
end
