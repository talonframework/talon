Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.Gen.ThemeTest do
  use ExUnit.Case
  import MixHelper

  alias Mix.Tasks.Talon.Gen.Theme, as: GenTheme

  @phx_web_path "lib/blogger/web"
  @phoenix_web_path "web"

  @phx_assets_path "assets"
  @phoenix_assets_path Path.join("web", "static")

  @default_phx_config %{
    base: "Blogger",
    binding: [
      alias: "Blogger",
      human: "Blogger",
      base: "Blogger",
      web_module: "Blogger.Web",
      module: "Blogger.Blogger",
      scoped: "Blogger",
      singular: "blogger",
      path: "blogger"
    ],
    boilerplate: true,
    web_path: "lib/blogger/web",
    dry_run: nil,
    resource: "Blog",
    scoped_resource: "Blogs.Blog",
    themes: ["admin_lte"],
    project_structure: :phx,
    verbose: false,
    lib_path: "lib/blogger",
    web_namespace: "Web."
  }

  @default_phoenix_config Enum.into([web_path: "web", scoped_resource: "Blog",
    project_structure: :phoenix, web_namespace: ""], @default_phx_config)

  describe "phx 1.3 structure" do
    test "new_1.3" do
      in_tmp "new_1.3", fn ->
        mk_web_path()
        mk_assets_path()
        GenTheme.run ~w(admin_lte admin_lte) ++ [~s(--web-path=lib/blogger/web), "--verbose", "--phx"]
        assert_file assets_path("static/images/talon/admin_lte/orderable.png")
        assert_file "assets/css/talon/admin-lte/talon.css"
        assert_file "assets/vendor/talon/admin-lte/bootstrap/css/bootstrap.min.css"
        assert_file "lib/blogger/web/templates/talon/admin_lte/layout/app.html.slim"
        assert_file "lib/blogger/web/views/talon/admin_lte/layout_view.ex", fn file ->
          file =~ "defmodule AdminLte.Web.LayoutView do"
          file =~ ~s(use Talon.Web, which: :view, theme: "admin_lte", module: AdminLte.Web)
        end
        assert_file "lib/blogger/web/templates/talon/admin_lte/generators/index.html.eex", fn file ->
          assert file =~ ~s(= AdminLte.Web.DatatableView.render_table)
        end
        assert_file "lib/blogger/web/templates/talon/admin_lte/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= AdminLte.Web.PaginateView.paginate)
        end
      end
    end
    # test "gen_images_1.3" do
    #   in_tmp "new_1.3", fn ->
    #     GenTheme.gen_images phx_config()
    #     assert_file assets_path("assets/images/talon/admin-lte/orderable.png")
    #   end
    # end
    # test "create phx view" do
    #   in_tmp "create_phx_view", fn ->
    #     mk_web_path()
    #     GenResource.create_view phx_config()
    #     assert_file web_path("views/talon/admin_lte/blog_view.ex"), fn file ->
    #       assert file =~ "defmodule AdminLte.Web.BlogView do"
    #     end
    #   end
    # end

    # test "create scoped resource file" do
    #   in_tmp "create_scoped_resource_file", fn ->
    #     mk_web_path()
    #     GenResource.create_resource_file phx_config()
    #     assert_file "lib/blogger/talon/blog.ex", fn file ->
    #       assert file =~ "defmodule Blogger.Talon.Blogs.Blog do"
    #       assert file =~ "use Talon.Resource, schema: Blogger.Blogs.Blog, context: Blogger.Talon"
    #     end
    #   end
    # end

    # test "create resource file" do
    #   in_tmp "create_resource_file", fn ->
    #     mk_web_path()
    #     GenResource.create_resource_file phx_config(scoped_resource: "Blog")
    #     assert_file "lib/blogger/talon/blog.ex", fn file ->
    #       assert file =~ "defmodule Blogger.Talon.Blog do"
    #       assert file =~ "use Talon.Resource, schema: Blogger.Blog, context: Blogger.Talon"
    #     end
    #   end
    # end
  end

  # describe "phoenix structure" do
  #   test "create phx view" do
  #     in_tmp "create_phx_view", fn ->
  #       mk_web_path()
  #       GenResource.create_view phoenix_config()
  #       assert_file web_path("views/talon/admin_lte/blog_view.ex", :phoenix), fn file ->
  #         assert file =~ "defmodule AdminLte.BlogView do"
  #       end
  #     end
  #   end

  #   test "create resource file" do
  #     in_tmp "create_resource_file", fn ->
  #       mk_web_path()
  #       GenResource.create_resource_file phoenix_config()
  #       assert_file "lib/blogger/talon/blog.ex", fn file ->
  #         assert file =~ "defmodule Blogger.Talon.Blog do"
  #         assert file =~ "use Talon.Resource, schema: Blogger.Blog, context: Blogger.Talon"
  #       end
  #     end
  #   end

  # end

  #################
  # Helpers

  defp web_path(path, which \\ :phx)
  defp web_path(path, :phx), do: Path.join(@phx_web_path, path)
  defp web_path(path, _), do: Path.join(@phoenix_web_path, path)

  defp assets_path(path, which \\ :phx)
  defp assets_path(path, :phx), do: Path.join(@phx_assets_path, path)
  defp assets_path(path, _), do: Path.join(@phoenix_assets_path, path)

  defp mk_web_path(path \\ @phx_web_path) do
    File.mkdir_p!(path)
  end

  defp mk_assets_path(path \\ @phx_assets_path) do
    File.mkdir_p!(path)
  end

  defp phoenix_config(opts \\ []) do
    Enum.into opts, @default_phoenix_config
  end

  defp phx_config(opts \\ []) do
    Enum.into opts, @default_phx_config
  end

end
