config :<%= config.app %>, <%= config.base %>.<%= config.concern %>,
  resources: [
  ],
  pages: [
  ],
  theme: "<%= theme %>",
  root_path: "<%= config.root_path %>",
  path_prefix: "<%= config.path_prefix %>",
  repo: <%= config.base %>.Repo,
  router: <%= config.web_base %>.Router,
  endpoint: <%= config.web_base %>.Endpoint,
  schema_adapter: Talon.Schema.Adapters.Ecto,
  messages_backend: <%= config.base %>.Talon.Messages

