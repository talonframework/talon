Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.Gen.ThemeTest do
  use ExUnit.Case
  import MixHelper
  import Talon.TestHelpers

  alias Mix.Tasks.Talon.Gen.Theme, as: GenTheme
  alias Mix.Tasks.Talon.New, as: GenNew

  @app_name "phx_blogger"

  setup do
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    {:ok, parsed: ~w(admin-lte admin-lte)}
  end

  describe "phx 1.3 structure" do
    test "new_1.3" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "theme_phx_blogger_defaults", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "theme_phx_blogger_defaults/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run ["--no-theme"] #{ }~w(--phx)
        Mix.Task.clear
        # mk_web_path()
        # mk_assets_path()
        GenTheme.run ["--verbose", "--phx"]

        assert_file assets_path("static/images/talon/admin-lte/orderable.png")
        assert_file "assets/css/talon/admin-lte/talon.css"
        assert_file "assets/vendor/talon/admin-lte/bootstrap/css/bootstrap.min.css"

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/dashboard_view.ex", [
          "defmodule PhxBlogger.Admin.AdminLte.Web.DashboardView do",
          ~s{use PhxBlogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web}
        ]
        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/dashboard/index.html.slim", [
          "Welcome to Talon",
          "To add dashboard sections, checkout 'lib/talon/admin/dashboard.ex'"
        ]

        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/layout/app.html.slim"
        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/layout_view.ex", [
          "defmodule PhxBlogger.Admin.AdminLte.Web.LayoutView do",
          ~s(use PhxBlogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web)
        ]
        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/generators/index.html.eex", fn file ->
          assert file =~ ~s(= PhxBlogger.Admin.AdminLte.Web.DatatableView.render_table)
        end
        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= render "table_and_paging.html", resources: @resources, conn: @conn)
        end
        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/components/datatable/table_and_paging.html.slim", fn file ->
          assert file =~ ~s(= PhxBlogger.Admin.AdminLte.Web.PaginateView.paginate)
        end
      end

    end

    test "second theme" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "second_theme", fn ->
        Mix.Task.clear
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "second_theme/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run [""] #{ }~w(--phx)
        Mix.Task.clear
        # mk_web_path()
        # mk_assets_path()
        GenTheme.run ["--phx", "--target-theme=front-end", "--concern=Front"]

        assert_file assets_path("static/images/talon/front-end/orderable.png")
        assert_file "assets/css/talon/front-end/talon.css"
        assert_file "assets/vendor/talon/front-end/bootstrap/css/bootstrap.min.css"
        assert_file "lib/phx_blogger/talon/templates/front/front-end/layout/app.html.slim"
        assert_file "lib/phx_blogger/talon/views/front/front-end/layout_view.ex", [
          "defmodule PhxBlogger.Front.FrontEnd.Web.LayoutView do",
          ~s(use PhxBlogger.Talon.Web, which: :view, theme: "front/front-end", module: PhxBlogger.Front.FrontEnd.Web)
        ]
        assert_file "lib/phx_blogger/talon/templates/front/front-end/generators/index.html.eex", fn file ->
          assert file =~ ~s(= PhxBlogger.Front.FrontEnd.Web.DatatableView.render_table)
        end
        assert_file "lib/phx_blogger/talon/templates/front/front-end/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= render "table_and_paging.html", resources: @resources, conn: @conn)
        end
        assert_file "lib/phx_blogger/talon/templates/front/front-end/components/datatable/table_and_paging.html.slim", fn file ->
          assert file =~ ~s(= PhxBlogger.Front.FrontEnd.Web.PaginateView.paginate)
        end
      end
    end

    @name "all_default_opts"
    test @name, %{parsed: parsed} do
      # {bin_opts, opts, parsed}
      in_tmp @name, fn ->
        mk_web_path()
        config = GenTheme.do_config {[phx: true], [], parsed}, []
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
          config = GenTheme.do_config {[{@opt, false} | [phx: true]], [], parsed}, []
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
          config = GenTheme.do_config {[only_opt | [phx: true]], [], parsed}, []
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

        assert_file brunch_file(:phx), fn file ->
          assert file =~ "'js/app.js': /^(js)|(node_modules)/,"
          assert file =~ "'js/talon/admin-lte/jquery-2.2.3.min.js': 'vendor/talon/admin-lte/plugins/jQuery/jquery-2.2.3.min.js',"

          assert file =~ "'css/app.css': /^(css)/,"
          assert file =~ "'css/talon/admin-lte/talon.css': ["
          assert file =~ "'css/talon/admin-lte/talon.css',"
        end
      end
    end
  end
  describe "phoenix structure" do
    test "brunch boilerplate appended" do
      Logger.disable(self())

      Application.put_env(:blogger, Blogger.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "theme_blogger_brunch", fn ->
        Mix.Tasks.Phoenix.New.run(["blogger", "--no-ecto"])
      end

      in_project :blogger, Path.join(tmp_path(), "theme_blogger_brunch/blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run ["--no-theme"] #{ }~w(--phx)
        Mix.Task.clear
        GenTheme.run  ["--proj-struct=phoenix", "--brunch-only"]

        assert_file brunch_file(:phoenix), fn file ->
          assert file =~ "'js/app.js': /^(web\\/static\\/js)|(node_modules)/,"
          assert file =~ "'js/talon/admin-lte/jquery-2.2.3.min.js': 'web/static/vendor/talon/admin-lte/plugins/jQuery/jquery-2.2.3.min.js',"

          assert file =~ "'css/app.css': /^(web\\/static\\/css)/,"
          assert file =~ "'css/talon/admin-lte/talon.css': ["
          assert file =~ "'web/static/css/talon/admin-lte/talon.css',"
        end
      end
    end

    test "new_phoenix" do
      Logger.disable(self())

      Application.put_env(:blogger, Blogger.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "theme_blogger_defaults", fn ->
        Mix.Tasks.Phoenix.New.run(["blogger", "--no-ecto"])
      end

      in_project :blogger, Path.join(tmp_path(), "theme_blogger_defaults/blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run ["--no-theme"] #{ }~w(--phx)
        Mix.Task.clear
        GenTheme.run [~s(--root-path=web),"--path-prefix=talon", "--verbose", "--phoenix"]

        assert_file assets_path("assets/images/talon/admin-lte/orderable.png", :phoenix)
        assert_file "web/static/css/talon/admin-lte/talon.css"
        assert_file "web/static/vendor/talon/admin-lte/bootstrap/css/bootstrap.min.css"
        assert_file "web/templates/talon/admin/admin-lte/layout/app.html.slim"
        assert_file "web/views/talon/admin/admin-lte/layout_view.ex", [
          "defmodule Blogger.Admin.AdminLte.LayoutView do",
          ~s(use Blogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: Blogger.Admin.AdminLte)
        ]
        assert_file "web/templates/talon/admin/admin-lte/generators/index.html.eex", fn file ->
          assert file =~ ~s(= Blogger.Admin.AdminLte.DatatableView.render_table)
        end
        assert_file "web/templates/talon/admin/admin-lte/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= render "table_and_paging.html", resources: @resources, conn: @conn)
        end
        assert_file "web/templates/talon/admin/admin-lte/components/datatable/table_and_paging.html.slim", fn file ->
          assert file =~ ~s(= Blogger.Admin.AdminLte.PaginateView.paginate)
        end

        assert_file "web/views/talon/admin/admin-lte/dashboard_view.ex", [
          "defmodule Blogger.Admin.AdminLte.DashboardView do",
          ~s(use Blogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: Blogger.Admin.AdminLte)
        ]

        assert_file "web/templates/talon/admin/admin-lte/dashboard/index.html.slim", [
          "To add dashboard sections, checkout 'lib/talon/admin/dashboard.ex'"
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
