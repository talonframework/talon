defmodule <%= base %>.<%= concern %>.<%= theme_module %>.<%= web_namespace %>PaginateView do
  use <%= base %>.Talon.Web, which: :component_view<%= view_opts %>

  use Talon.Components.Paginate
  import Talon.Utils, only: [to_integer: 1]

  def paginate(%{params: params} = conn) do
    link = Talon.Concern.resource_path conn, :index, [Map.drop(params, ["resource", "page"])]
    page_number = to_integer(params["page"] || 1)
    page = conn.assigns[:page]
    model_name =
      conn.assigns[:resource]
      |> Module.split
      |> List.last

    paginate(link, page_number, page.page_size, page.total_pages, page.total_entries, model_name, show_information: true)
  end
end
