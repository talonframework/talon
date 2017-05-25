use Mix.Config

config :talon, resources: [
],
module: <%= base %>,
messages_backend: <%= base %>.Gettext,
theme: "<%= theme %>",
schema_adapter: Talon.Schema.Adapters.Ecto

