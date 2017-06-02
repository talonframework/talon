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

config :talon, TestTalon.Talon,
  resources: [
    TestTalon.Talon.Simple,
    TestTalon.Talon.Product,
    # TestTalon.Talon.Dashboard,
    # TestTalon.Talon.Noid,
    # TestTalon.Talon.User,
    # TestTalon.Talon.Simple,
    # TestTalon.Talon.ModelDisplayName,
    # TestTalon.Talon.DefnDisplayName,
    # TestTalon.Talon.RestrictedEdit,
  ],
  schema_adapter: Talon.Schema.Adapters.Ecto,
  module: TestTalon,
  endpoint: TestTalon.Endpoint,
  repo: TestTalon.Repo,
  router: TestTalon.Router,
  theme: "admin-lte"

config :talon, TestTalon.FrontEnd,
  resources: [
    TestTalon.FrontEnd.Noid
  ],
  schema_adapter: Talon.Schema.Adapters.Ecto,
  module: TestTalon,
  endpoint: TestTalon.Endpoint,
  repo: TestTalon.Repo,
  router: TestTalon.Router,
  theme: "theme2"

config :talon,
  concerns: [TestTalon.Talon, TestTalon.FrontEnd],
  schema_adapter: Talon.Schema.Adapters.Ecto,
  module: TestTalon

config :logger, level: :error
