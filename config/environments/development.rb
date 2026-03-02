require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Make code changes take effect immediately
  config.enable_reloading = true

  # Do not eager load code on boot
  config.eager_load = false

  # Show full error reports
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Caching
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.public_file_server.headers = {
      "cache-control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  config.cache_store = :memory_store

  # Local file storage
  config.active_storage.service = :local

  # Mailer config
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # 🔥 IMPORTANT: Enable real email sending
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.smtp_settings = {
    address: "smtp.gmail.com",
    port: 587,
    domain: "localhost",
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: "plain",
    enable_starttls_auto: true
  }

  # Deprecations
  config.active_support.deprecation = :log

  # Raise error on pending migrations
  config.active_record.migration_error = :page_load

  # Query logs
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true

  # Job logs
  config.active_job.verbose_enqueue_logs = true

  # Redirect logs
  config.action_dispatch.verbose_redirect_logs = true

  # Annotate rendered views
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error for invalid before_action usage
  config.action_controller.raise_on_missing_callback_actions = true
end

# CORS configuration (keep outside configure block)
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:3001"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      max_age: 600
  end
end
