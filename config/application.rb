require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Blog
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

	# See https://codereview.stackexchange.com/questions/144435/set-env-variables-for-ruby-on-rails :
	# SECRETS = Rails.application.secrets
	# ENV[:database_password] = Rails.application.secrets[:database_password]
	ENV['DATABASE_USERNAME'] = Rails.application.secrets[:database_username]
	ENV['DATABASE_PASSWORD'] = Rails.application.secrets[:database_password]
  end
end
