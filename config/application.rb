require_relative "boot"

require "rails/all"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Monitoring
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_paths << "#{Rails.root}/lib"

    config.after_initialize do
      client = Octokit::Client.new(:access_token => ENV['PERSONAL_ACCESS_TOKEN'])
      Repository.all.each do |repo|
        Services::Monitoring.set_repo_latest_release(repo, client)
        repo.save
      end
    end

    Rails.logger = Logger.new(STDOUT)
    config.logger = ActiveSupport::Logger.new("log/#{Rails.env}.log")
  end
end