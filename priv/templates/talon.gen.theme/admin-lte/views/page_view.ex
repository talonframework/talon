defmodule <%= base %>.<%= concern %>.<%= target_module %>.<%= web_namespace %><%= page %>View do
  use <%= base %>.Talon.Web, which: :view<%= view_opts %>

end
