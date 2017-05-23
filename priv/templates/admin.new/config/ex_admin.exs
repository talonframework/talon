use Mix.Config

config :ex_admin, resources: [
],
module: <%= base %>,
messages_backend: <%= base %>.Gettext,
theme: "<%= theme %>",
schema_adapter: ExAdmin.Schema.Adapters.Ecto

