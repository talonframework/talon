use Mix.Config

config :<%= config.app %>, :talon,
  module: <%= config.base %>,
  themes: ["<%= theme %>"],
  concerns: [<%= config.base %>.<%= config.concern %>],
  <%= if config.web_namespace == "" do %>
  web_namespace: nil
  <% else %>
  web_namespace: Web
  <% end %>

<%= EEx.eval_file path, theme: theme, config: config %>
