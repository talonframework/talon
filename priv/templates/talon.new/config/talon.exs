use Mix.Config

config :talon, resources: [
],
module: <%= base %>,
messages_backend: <%= base %>.<%= web_namespace %>Gettext,
theme: "<%= theme %>",
<%= if web_namespace == "" do %>
web_namespace: nil,
<% else %>
web_namespace: Web,
<% end %>
schema_adapter: Talon.Schema.Adapters.Ecto

