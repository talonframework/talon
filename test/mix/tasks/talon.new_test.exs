Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.NewTest do
  use ExUnit.Case
  import MixHelper
  # import Talon.TestHelpers
  # import ExUnit.CaptureIO

  alias Mix.Tasks.Talon.New, as: GenNew

  # @epoch {{1970, 1, 1}, {0, 0, 0}}

  setup do
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    {:ok, parsed: ~w(admin-lte admin-lte)}
  end

  @app_name "phx_blogger"

  describe "phx-1.3 structure" do
    test "talon.new", %{parsed: _parsed} do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "phx_blogger", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "phx_blogger/phx_blogger"), fn _ ->
        Mix.Task.clear

        GenNew.run [] #{ }~w(--phx)

        assert_file "config/config.exs", [
          ~s/import_config "talon.exs"/,
          ~s/slim: PhoenixSlime.Engine,/
        ]

        assert_file "mix.exs",
          "compilers: [:talon, :phoenix, :gettext] ++ Mix.compilers,"

        assert_file "lib/phx_blogger/talon/admin/admin.ex", fn file ->
          assert file =~ "defmodule PhxBlogger.Admin do"
          assert file =~ "use Talon.Concern, otp_app: :phx_blogger"
        end

        assert_file "config/talon.exs", [
          "config :phx_blogger,",
          "module: PhxBlogger,",
          "web_namespace: Web"
        ]

        assert_file "lib/phx_blogger/talon/web.ex", [
          "import PhxBlogger.Web.Router.Helpers",
          "import PhxBlogger.Web.ErrorHelpers",
          "import PhxBlogger.Web.Gettext",
        ]

        assert_file "lib/phx_blogger/talon/controllers/admin_resource_controller.ex", [
          "defmodule PhxBlogger.Web.AdminResourceController do",
          "use PhxBlogger.Web, :controller",
          "use Talon.Controller, repo: PhxBlogger.Repo, concern: PhxBlogger.Admin"
        ]

        assert_file "lib/phx_blogger/talon/controllers/admin_page_controller.ex", [
          "defmodule PhxBlogger.Web.TalonPageController do",
          "use PhxBlogger.Web, :controller",
          "use Talon.PageController, concern: PhxBlogger.Admin",
          "plug Talon.Plug.LoadConcern",
          "plug Talon.Plug.Theme",
          "plug Talon.Plug.Layout",
          "plug Talon.Plug.View"
        ]

        assert_file "lib/phx_blogger/talon/admin/dashboard.ex", [
          "defmodule PhxBlogger.Admin.Dashboard",
          "use Talon.Page, concern: PhxBlogger.Admin"
          # TODO: test for boilerplate
        ]

        assert_file "lib/phx_blogger/talon/messages.ex", [
          "defmodule PhxBlogger.Talon.Messages do",
          "import PhxBlogger.Web.Gettext"
        ]

        #########
        # Views

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/layout_view.ex", [
          "defmodule PhxBlogger.Admin.AdminLte.Web.LayoutView do",
          ~s{use PhxBlogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web}
        ]

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/components/datatable_view.ex", [
          "defmodule PhxBlogger.Admin.AdminLte.Web.DatatableView do",
          ~s{use PhxBlogger.Talon.Web, which: :component_view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web},

          "use Talon.Components.Datatable, __MODULE__"
        ]

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/components/paginate_view.ex", [
          "defmodule PhxBlogger.Admin.AdminLte.Web.PaginateView do",
          ~s{use PhxBlogger.Talon.Web, which: :component_view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web}
        ]

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/dashboard_view.ex", [
          "defmodule PhxBlogger.Admin.AdminLte.Web.DashboardView do",
          ~s{use PhxBlogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web}
        ]

        #########
        # templates
        base_path = Path.join(~w(lib phx_blogger talon templates admin admin-lte))
        path = Path.join(base_path, "generators")
        datatable_path = Path.join([base_path, "components", "datatable"])

        assert_file Path.join(path, "edit.html.eex")
        assert_file Path.join(path, "form.html.eex")
        assert_file Path.join(path, "index.html.eex"), [
          "= PhxBlogger.Admin.AdminLte.Web.DatatableView.render_table(@conn, @resources)"
        ]
        assert_file Path.join(path, "new.html.eex")
        assert_file Path.join(path, "show.html.eex")

        assert_file Path.join(datatable_path, "datatable.html.slim"), [
          "= PhxBlogger.Admin.AdminLte.Web.PaginateView.paginate(@conn)"
        ]
        assert_file Path.join(datatable_path, "table_body.html.slim")
        for file <- ~w(app nav_action_link nav_resource_link sidebar) do
          assert_file Path.join([base_path, "layout", "#{file}.html.slim"])
        end

        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/dashboard/dashboard.html.slim", [
          "Welcome to Talon",
          "To add dashboard sections, checkout"
        ]
      end
    end
  end

  @app_name "blogger"

  describe "phoenix structure" do
    test "talon.new", %{parsed: _parsed} do
      Logger.disable(self())

      Application.put_env(:blogger, Blogger.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "blogger", fn ->
        Mix.Tasks.Phoenix.New.run([@app_name, "--no-ecto"])
      end

      in_project :blogger, Path.join(tmp_path(), "blogger/blogger"), fn _ ->
        Mix.Task.clear

        GenNew.run [] #{ }~w(--phx)

        assert_file "config/config.exs", [
          ~s/import_config "talon.exs"/,
          ~s/slim: PhoenixSlime.Engine,/
        ]

        assert_file "mix.exs",
          "compilers: [:talon, :phoenix, :gettext] ++ Mix.compilers,"

        assert_file "lib/blogger/talon/admin/admin.ex", fn file ->
          assert file =~ "defmodule Blogger.Admin do"
          assert file =~ "use Talon.Concern, otp_app: :blogger"
        end

        assert_file "config/talon.exs", [
          "config :blogger,",
          "module: Blogger,",
          ~s/theme: "admin-lte",/,
          "schema_adapter: Talon.Schema.Adapters.Ecto"
        ]

        assert_file "lib/blogger/talon/web.ex", [
          "import Blogger.Router.Helpers",
          "import Blogger.ErrorHelpers",
          "import Blogger.Gettext",
        ]

        assert_file "lib/blogger/talon/controllers/admin_resource_controller.ex", [
          "defmodule Blogger.AdminResourceController do",
          "use Blogger.Web, :controller",
          "use Talon.Controller, repo: Blogger.Repo, concern: Blogger.Admin"
        ]

        assert_file "lib/blogger/talon/messages.ex", [
          "defmodule Blogger.Talon.Messages do",
          "import Blogger.Gettext"
        ]

        assert_file "lib/blogger/talon/views/admin/admin-lte/layout_view.ex", [
          "defmodule Blogger.Admin.AdminLte.LayoutView do",
          ~s{use Blogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: Blogger.Admin.AdminLte}
        ]

        assert_file "lib/blogger/talon/views/admin/admin-lte/components/datatable_view.ex", [
          "defmodule Blogger.Admin.AdminLte.DatatableView do",
          ~s{use Blogger.Talon.Web, which: :component_view, theme: "admin/admin-lte", module: Blogger.Admin.AdminLte},
          "use Talon.Components.Datatable, __MODULE__"
        ]

        assert_file "lib/blogger/talon/views/admin/admin-lte/components/paginate_view.ex", [
          "defmodule Blogger.Admin.AdminLte.PaginateView do",
          ~s{use Blogger.Talon.Web, which: :component_view, theme: "admin/admin-lte", module: Blogger.Admin.AdminLte}
        ]

        assert_file "lib/blogger/talon/controllers/admin_page_controller.ex", [
          "defmodule Blogger.TalonPageController do",
          "use Blogger.Web, :controller",
          "use Talon.PageController, concern: Blogger.Admin",
          "plug Talon.Plug.LoadConcern",
          "plug Talon.Plug.Theme",
          "plug Talon.Plug.Layout",
          "plug Talon.Plug.View"
        ]

        assert_file "lib/blogger/talon/admin/dashboard.ex", [
          "defmodule Blogger.Admin.Dashboard",
          "use Talon.Page, concern: Blogger.Admin"
          # TODO: test for boilerplate
        ]

        #########
        # templates

        assert_file "lib/blogger/talon/templates/admin/admin-lte/generators/edit.html.eex"
        assert_file "lib/blogger/talon/templates/admin/admin-lte/generators/form.html.eex"
        assert_file "lib/blogger/talon/templates/admin/admin-lte/generators/index.html.eex", [
          "= Blogger.Admin.AdminLte.DatatableView.render_table(@conn, @resources)"
        ]
        assert_file "lib/blogger/talon/templates/admin/admin-lte/generators/new.html.eex"
        assert_file "lib/blogger/talon/templates/admin/admin-lte/generators/show.html.eex"
        assert_file "lib/blogger/talon/templates/admin/admin-lte/components/datatable/datatable.html.slim", [
          "= Blogger.Admin.AdminLte.PaginateView.paginate(@conn)"
        ]
        assert_file "lib/blogger/talon/templates/admin/admin-lte/components/datatable/table_body.html.slim"
        for file <- ~w(app nav_action_link nav_resource_link sidebar) do
          assert_file "lib/blogger/talon/templates/admin/admin-lte/layout/#{file}.html.slim"
        end

        assert_file "lib/blogger/talon/templates/admin/admin-lte/dashboard/dashboard.html.slim", [
          "Welcome to Talon",
          "To add dashboard sections, checkout"
        ]
      end
    end
  end

  #################
  # Helpers

end
