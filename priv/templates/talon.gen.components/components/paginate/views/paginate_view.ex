defmodule <%= theme_module %>.PaginateView do
  use Phoenix.View, root: "web/templates/talon/<%= theme_name %>/components"
  use Talon.Web, :view

  import Talon.Components.Paginate
  import Talon.Utils, only: [to_integer: 1]

  def paginate(%{params: params} = conn) do
    page_number = to_integer(params["page"] || 1)
    page = conn.assigns[:page]
    model_name =
      conn.assigns[:resource]
      |> Module.split
      |> List.last
    link = Talon.Utils.talon_resource_path conn.assigns[:resource], :index, [[order: nil]]

    paginate(link, page_number, page.page_size, page.total_pages, page.total_entries, model_name, show_information: true)
  end
end
