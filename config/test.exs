use Mix.Config

config :talon,
  ecto_repos: [TestTalon.Repo]

config :talon, TestTalon.Endpoint,
  http: [port: 4001],
  secret_key_base: "HL0pikQMxNSA58DV3mf26O/eh1e4vaJDmx1qLgqBcnS14gbKu9Xn3x114D+mHYcX",
  server: false

config :talon, TestTalon.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "talon_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :talon, TestTalon.Admin,
  resources: [
    TestTalon.Admin.Simple,
    TestTalon.Admin.Product,
  ],
  schema_adapter: Talon.Schema.Adapters.Ecto,
  module: TestTalon,
  endpoint: TestTalon.Endpoint,
  repo: TestTalon.Repo,
  router: TestTalon.Router,
  root_path: "test/support/fixtures/talon",
  path_prefix: "",
  theme: "admin-lte",
  messages_backend: TestTalon.Talon.Messages

config :talon, TestTalon.FrontEnd,
  resources: [
    TestTalon.FrontEnd.Noid
  ],
  schema_adapter: Talon.Schema.Adapters.Ecto,
  module: TestTalon,
  endpoint: TestTalon.Endpoint,
  repo: TestTalon.Repo,
  router: TestTalon.Router,
  theme: "theme2",
  root_path: "test/support/fixtures/talon",
  path_prefix: "",
  messages_backend: TestTalon.Talon.Messages

config :talon, :talon,
  module: TestTalon,
  concerns: [TestTalon.Admin, TestTalon.FrontEnd],
  themes: ["admin-lte", "theme2"]

config :logger, level: :error
