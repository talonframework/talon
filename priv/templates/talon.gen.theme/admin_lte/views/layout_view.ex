defmodule <%= target_module %>.<%= web_namespace %>LayoutView do
  use Talon.Web, :component_view, theme: "<%= theme_name %>", module: <%= theme_module %>.<%= web_namespace %>

end
