ManybotsGithub::Engine.routes.draw do
  
  resources :github do
    collection do
      get 'callback'
    end
    member do
      post 'import'
    end
  end
  
  root :to => 'github#index'
  
end
