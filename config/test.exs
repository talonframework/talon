use Mix.Config

config :ex_admin,
  ecto_repos: [TestExAdmin.Repo]

config :ex_admin, TestExAdmin.Endpoint,
  http: [port: 4001],
  secret_key_base: "HL0pikQMxNSA58DV3mf26O/eh1e4vaJDmx1qLgqBcnS14gbKu9Xn3x114D+mHYcX",
  server: false

config :ex_admin, TestExAdmin.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ex_admin_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :ex_admin, TestExAdmin.Admin,
  resources: [
    TestExAdmin.ExAdmin.Simple,
    TestExAdmin.ExAdmin.Product,
    # TestExAdmin.ExAdmin.Dashboard,
    # TestExAdmin.ExAdmin.Noid,
    # TestExAdmin.ExAdmin.User,
    # TestExAdmin.ExAdmin.Simple,
    # TestExAdmin.ExAdmin.ModelDisplayName,
    # TestExAdmin.ExAdmin.DefnDisplayName,
    # TestExAdmin.ExAdmin.RestrictedEdit,
  ],
  schema_adapter: ExAdmin.Schema.Adapters.Ecto,
  module: TestExAdmin,
  theme: "admin_lte"


config :ex_admin,
  schema_adapter: ExAdmin.Schema.Adapters.Ecto,
  module: TestExAdmin,
  theme: "admin_lte",
  resources: [
    TestExAdmin.ExAdmin.Simple,
    TestExAdmin.ExAdmin.Product,
  ]

config :logger, level: :error
