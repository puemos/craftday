import Config

config :craftday, Craftday.Repo,
  # For development, we disable any cache and enable
  # debugging and code reloading.
  #
  # The watchers configuration can be used to run external
  # watchers to your application. For example, we can use it
  # to bundle .js and .css sources.
  username: "postgres",
  # Binding to loopback ipv4 address prevents access from other machines.
  # Watch static and templates for browser reloading.
  password: "postgres",
  hostname: "localhost",
  database: "craftday_dev",
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :craftday, CraftdayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  # ## SSL Support
  #
  # In order to use HTTPS in development, a self-signed
  # certificate can be generated by running the following
  # Mix task:
  #
  # Enable dev routes for dashboard and mailbox

  #     mix phx.gen.cert
  #

  #
  # The `http:` config above can be replaced with:

  # Run `mix help phx.gen.cert` for more information.
  #
  #     https: [
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "NlbIq9/9aO9+5xxg8ESxxFI7ay172FlEI5IVJvhLx50ZcZbWLjV1L1ito7aZ0fiM",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :craftday, CraftdayWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/craftday_web/(controllers|live|components)/.*(ex|heex)$",
      ~r"storybook/.*(exs)$"
    ]

    #       certfile: "priv/cert/selfsigned.pem"

    # Do not include metadata nor timestamps in development logs
    # in production as building large stacktraces may be expensive.
    # Include HEEx debug annotations as HTML comments in rendered markup
    #       cipher_suite: :strong,
    #       keyfile: "priv/cert/selfsigned_key.pem",
  ]

#       port: 4001,
# Configure your database
#     ],
# configured to run both http and https servers on
#
# different ports.
config :craftday, dev_routes: true, token_signing_secret: "1Y4H7uJJNzu5KtTktCIrtiyGZ+A0eBS9"

config :ex_aws,
  json_codec: Jason,
  access_key_id: "minio",
  secret_access_key: "minio123",
  region: "us-east-1",
  s3: [
    scheme: "http://",
    host: "localhost",
    port: 9000,
    region: "us-east-1"
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :plug_init_mode, :runtime
# If desired, both `http:` and `https:` keys can be
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

config :swoosh, :api_client, false

config :waffle,
  storage: Waffle.Storage.S3,
  bucket: "craftday",
  asset_host: "http://localhost:9000/craftday"

# Set a higher stacktrace during development. Avoid configuring such
# Disable swoosh api client as it is only required for production adapters.
# Initialize plugs at runtime for faster development compilation
