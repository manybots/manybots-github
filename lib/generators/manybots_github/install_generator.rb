require 'rails/generators'
require 'rails/generators/base'
require 'rails/generators/migration'


module ManybotsGithub
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      source_root File.expand_path("../../templates", __FILE__)
      
      class_option :routes, :desc => "Generate routes", :type => :boolean, :default => true
      class_option :migrations, :desc => "Generate migrations", :type => :boolean, :default => true
      
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      desc 'Mounts Github Observer at "/manybots-github"'
      def add_manybots_github_routes
        route 'mount ManybotsGithub::Engine => "/manybots-github"' if options.routes?
      end
      
      desc "Copies ManybotsGithub migrations"
      def create_model_file
        migration_template "create_manybots_github_repositories.rb", "db/migrate/create_manybots_github_repositories.manybots_github.rb"
        migration_template "create_manybots_github_commits.rb", "db/migrate/create_manybots_github_commits.manybots_github.rb"
      end
      
      desc "Creates a ManybotsGithub initializer"
      def copy_initializer
        template "manybots-github.rb", "config/initializers/manybots-github.rb"
      end
      
      def show_readme
        readme "README" if behavior == :invoke
      end
      
    end
  end
end
