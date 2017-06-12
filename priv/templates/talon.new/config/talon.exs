use Mix.Config

config :<%= app %>, :talon,
  module: <%= base %>,
  messages_backend: <%= base %>.<%= web_namespace %>Gettext,
  <%= if web_namespace == "" do %>
  web_namespace: nil
  <% else %>
  web_namespace: Web
  <% end %>

<%= EEx.eval_file path, app: app, base: base, concern: concern,
  theme: theme %>
