Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.Gen.ThemeTest do
  use ExUnit.Case
  import MixHelper
  import Talon.TestHelpers

  alias Mix.Tasks.Talon.Gen.Theme, as: GenTheme


  # @default_phx_config %{
  #   base: "Blogger",
  #   binding: [
  #     alias: "Blogger",
  #     human: "Blogger",
  #     base: "Blogger",
  #     web_module: "Blogger.Web",
  #     module: "Blogger.Blogger",
  #     scoped: "Blogger",
  #     singular: "blogger",
  #     path: "blogger"
  #   ],
  #   boilerplate: true,
  #   web_path: "lib/blogger/web",
  #   dry_run: nil,
  #   resource: "Blog",
  #   scoped_resource: "Blogs.Blog",
  #   themes: ["admin_lte"],
  #   project_structure: :phx,
  #   verbose: false,
  #   lib_path: "lib/blogger",
  #   web_namespace: "Web."
  # }

  # @default_phoenix_config Enum.into([web_path: "web", scoped_resource: "Blog",
  #   project_structure: :phoenix, web_namespace: ""], @default_phx_config)

  setup do
    {:ok, parsed: ~w(admin_lte admin_lte)}
  end

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
        assert_file "lib/blogger/web/views/talon/admin_lte/layout_view.ex", [
          "defmodule AdminLte.Web.LayoutView do",
          ~s(use Talon.Web, which: :view, theme: "admin_lte", module: AdminLte.Web)
        ]
        assert_file "lib/blogger/web/views/talon/admin_lte/dashboard_view.ex", [
          "defmodule AdminLte.Web.DashboardView do",
          ~s/use Talon.Web, which: :view, theme: "admin_lte", module: AdminLte.Web/
        ]
        assert_file "lib/blogger/web/templates/talon/admin_lte/generators/index.html.eex", [
          ~s(= AdminLte.Web.DatatableView.render_table)
        ]
        assert_file "lib/blogger/web/templates/talon/admin_lte/components/datatable/datatable.html.slim", [
          ~s(= AdminLte.Web.PaginateView.paginate)
        ]
        assert_file "lib/blogger/web/templates/talon/admin_lte/dashboard/dashboard.html.slim", [
          "Welcome to Talon",
          "To add dashboard sections, checkout 'lib/talon/dashboard.ex'"
        ]
      end

    end

    @name "all_default_opts"
    test @name, %{parsed: parsed} do
      # {bin_opts, opts, parsed}
      in_tmp @name, fn ->
        mk_web_path()
        config = GenTheme.do_config {[phx: true], [], parsed}
        Enum.each ~w(brunch assets layouts generators components)a, fn option ->
          assert config[option]
        end
      end
    end

    for opt <- ~w(brunch assets layouts generators components)a do
      @name "disable #{inspect opt}"
      @opt opt
      test @name, %{parsed: parsed} do
        # {bin_opts, opts, parsed}
        in_tmp @name, fn ->
          mk_web_path()
          config = GenTheme.do_config {[{@opt, false} | [phx: true]], [], parsed}
          Enum.each ~w(brunch assets layouts generators components)a, fn option ->
            if option == @opt do
              refute config[option]
            else
              assert config[option]
            end
          end
        end
      end
    end

    for opt <- ~w(brunch assets layouts generators components)a do
      @name "#{inspect opt}-only options"
      @opt opt
      test @name, %{parsed: parsed} do
        # {bin_opts, opts, parsed}
        in_tmp @name, fn ->
          mk_web_path()
          only_opt = {String.to_atom("#{@opt}_only"), true}
          config = GenTheme.do_config {[only_opt | [phx: true]], [], parsed}
          Enum.each ~w(brunch assets layouts generators components)a, fn option ->
            if option == @opt do
              assert config[option]
            else
              refute config[option]
            end
          end
        end
      end
    end

    test "brunch boilerplate appended", %{parsed: parsed} do
      in_tmp "brunch boilerplate appended", fn ->
        mk_web_path()
        mk_brunch_file(:phx)

        GenTheme.run  parsed ++ ["--proj-struct=phx", "--brunch-only"]

        assert_file brunch_file(:phx), [
          "'js/app.js': /^(js)|(node_modules)/,",
          "'js/talon/admin_lte/jquery-2.2.3.min.js': 'vendor/talon/admin-lte/plugins/jQuery/jquery-2.2.3.min.js',",

          "'css/app.css': /^(css)/,",
          "'css/talon/admin_lte/talon.css': [",
          "'css/talon/admin-lte/talon.css',"
        ]
      end
    end
  end
  describe "phoenix structure" do
    test "brunch boilerplate appended", %{parsed: parsed} do
      in_tmp "brunch boilerplate appended phoenix", fn ->
        mk_web_path()
        mk_brunch_file(:phoenix)

        GenTheme.run  parsed ++ ["--proj-struct=phoenix", "--brunch-only"]

        assert_file brunch_file(:phoenix), [
          "'js/app.js': /^(web\\/static\\/js)|(node_modules)/,",
          "'js/talon/admin_lte/jquery-2.2.3.min.js': 'web/static/vendor/talon/admin-lte/plugins/jQuery/jquery-2.2.3.min.js',",

          "'css/app.css': /^(web\\/static\\/css)/,",
          "'css/talon/admin_lte/talon.css': [",
          "'web/static/css/talon/admin-lte/talon.css',"
        ]
      end
    end

    test "new_phoenix" do
      in_tmp "new_phoenix", fn ->

        mk_phoenix_project()
        # mk_web_path(@phoenix_web_path)
        # mk_assets_path(@phoenix_assets_path)
        GenTheme.run ~w(admin_lte admin_lte) ++ [~s(--web-path=web), "--verbose", "--phoenix"]
        assert_file assets_path("assets/images/talon/admin_lte/orderable.png", :phoenix)
        assert_file "web/static/css/talon/admin-lte/talon.css"
        assert_file "web/static/vendor/talon/admin-lte/bootstrap/css/bootstrap.min.css"
        assert_file "web/templates/talon/admin_lte/layout/app.html.slim"
        assert_file "web/views/talon/admin_lte/layout_view.ex", [
          "defmodule AdminLte.LayoutView do",
          ~s(use Talon.Web, which: :view, theme: "admin_lte", module: AdminLte)
        ]
        assert_file "web/templates/talon/admin_lte/generators/index.html.eex", [
          ~s(= AdminLte.DatatableView.render_table)
        ]
        assert_file "web/templates/talon/admin_lte/components/datatable/datatable.html.slim", [
          ~s(= AdminLte.PaginateView.paginate)
        ]
      end
    end
  end

  #################
  # Helpers

  # defp web_path(path, which \\ :phx)
  # defp web_path(path, :phx), do: Path.join(@phx_web_path, path)
  # defp web_path(path, _), do: Path.join(@phoenix_web_path, path)

end
