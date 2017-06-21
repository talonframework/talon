defmodule <%= base %>.<%= concern %>.<%= target_module %>.<%= web_namespace %>LayoutView do
  use <%= base %>.Talon.Web, which: :view<%= view_opts %>

end
