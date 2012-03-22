# Github Observer

manybots-github is a Manybots Observer that allows you to import your Github commits into your local Manybots.

On Manybots, your commits will look like this:
webcracy commit to webcracy/manybots-github - first commit (SHA)

## Installation instructions

### Setup the gem

You need the latest version of Manybots Local running on your system. Open your Terminal and `cd` into its' directory.

First, require the gem: edit your `Gemfile`, add the following, and run `bundle install`

```
gem 'manybots-github', :git => 'git://github.com/manybots/manybots-github.git'
gem 'octokit', '1.0.0', :git => 'git://github.com/webcracy/octokit.git'
```

Second, run the manybots-github install generator (mind the underscore):

```
rails g manybots_github:install
bundle exec rake db:migrate
```

Now you need to register your Github Observer with Github.

### Register your Github Observer with Github

Your Github Observer uses OAuth to authorize you (and/or your other Manybots Local users) with Github. 

1. Go to this link: https://github.com/settings/applications/new

2. Enter information like described in the screenshot below. The URL must be the one of your Manybots Local installation.

<img src="https://img.skitch.com/20120305-g8xjede9xjeccssa2fpxyybb79.png" />

Once you submit, you'll get a window like the one below:

<img src="https://img.skitch.com/20120305-r6idb7r8is8eugufuf1fqa1ndi.png" />

Copy the Client ID and Secret into `config/initializers/manybots-github.rb`

```
  config.github_app_id = 'Client ID'
  config.github_app_secret = 'Secret'
```  


### Restart and go!

Restart your server and you'll see the Github Observer in your `/apps` catalogue. Go to the app, sign-in to your Github Account and start importing your commits into Manybots.