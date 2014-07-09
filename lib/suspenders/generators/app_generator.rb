require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Suspenders
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :database, :type => :string, :aliases => '-d', :default => 'sqlite3',
      :desc => "Preconfigure for selected database (options: #{DATABASES.join('/')})"

    class_option :skip_test_unit, :type => :boolean, :aliases => '-T', :default => true,
      :desc => 'Skip Test::Unit files'

    def finish_template
      invoke :suspenders_customization
      super
    end

    def suspenders_customization
      invoke :customize_gemfile
      invoke :setup_development_environment
      invoke :setup_test_environment
      invoke :setup_production_environment
      invoke :setup_staging_environment
      invoke :setup_secret_token
      invoke :create_suspenders_views
      invoke :setup_coffeescript
      invoke :configure_app
      invoke :setup_stylesheets
      invoke :copy_miscellaneous_files
      invoke :customize_error_pages
      invoke :remove_routes_comment_lines
      invoke :setup_git
      invoke :setup_database
      invoke :outro
    end

    def customize_gemfile
      build :replace_gemfile
      build :set_ruby_to_version_being_used

      bundle_command 'install'
    end

    def setup_database
      say 'Setting up database'

      if 'postgresql' == options[:database]
        build :use_postgres_config_template
      end

      if 'sqlite3' == options[:database]
        build :use_sqlite_config_template
      end

      build :create_database
    end

    def setup_development_environment
      say 'Setting up the development environment'
      build :raise_on_delivery_errors
      build :raise_on_unpermitted_parameters
      build :provide_setup_script
      build :provide_dev_prime_task
      build :configure_generators
    end

    def setup_test_environment
      say 'Setting up the test environment'
      build :set_up_factory_girl_for_rspec
      build :generate_rspec
      build :configure_rspec
      build :enable_database_cleaner
      build :configure_spec_support_features
      build :configure_travis
      build :configure_i18n_in_specs
      build :configure_action_mailer_in_specs
    end

    def setup_production_environment
      say 'Setting up the production environment'
      build :configure_newrelic
      build :enable_rack_deflater
      build :setup_asset_host
    end

    def setup_staging_environment
      say 'Setting up the staging environment'
      build :setup_staging_environment
    end

    def setup_secret_token
      say 'Moving secret token out of version control'
      build :setup_secret_token
    end

    def create_suspenders_views
      say 'Creating suspenders views'
      build :create_partials_directory
      build :create_shared_flashes
      build :create_shared_javascripts
      build :create_application_layout
    end

    def setup_coffeescript
      say 'Setting up CoffeeScript defaults'
      build :remove_turbolinks
    end

    def configure_app
      say 'Configuring app'
      build :configure_action_mailer
      build :configure_time_zone
      build :configure_time_formats
      build :configure_rack_timeout
      build :disable_xml_params
      build :fix_i18n_deprecation_warning
      build :setup_default_rake_task
      build :configure_unicorn
    end

    def setup_stylesheets
      say 'Set up stylesheets'
      build :setup_stylesheets
    end

    def setup_git
      if !options[:skip_git]
        say 'Initializing git'
        invoke :setup_gitignore
        invoke :init_git
      end
    end

    def setup_gitignore
      build :gitignore_files
    end

    def init_git
      build :init_git
    end

    def copy_miscellaneous_files
      say 'Copying miscellaneous support files'
      build :copy_miscellaneous_files
    end

    def customize_error_pages
      say 'Customizing the 500/404/422 pages'
      build :customize_error_pages
    end

    def remove_routes_comment_lines
      build :remove_routes_comment_lines
    end

    def outro
      say 'Congratulations! You just pulled our suspenders.'
      say "Remember to run 'rails generate airbrake' with your API key."
    end

    def run_bundle
      # Let's not: We'll bundle manually at the right spot
    end

    protected

    def get_builder_class
      Suspenders::AppBuilder
    end

    def using_active_record?
      !options[:skip_active_record]
    end
  end
end
