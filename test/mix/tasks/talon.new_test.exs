Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.NewTest do
  use ExUnit.Case
  import MixHelper
  # import ExUnit.CaptureIO

  alias Mix.Tasks.Talon.New, as: GenNew

  # @epoch {{1970, 1, 1}, {0, 0, 0}}

  setup do
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    {:ok, parsed: ~w(admin_lte admin_lte)}
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

        assert_file "lib/phx_blogger/talon/talon.ex", fn file ->
          assert file =~ "defmodule PhxBlogger.Talon do"
          assert file =~ "use Talon, otp_app: :phx_blogger"
        end

        assert_file "config/talon.exs", [
          "config :talon,",
          "module: PhxBlogger,",
          "essages_backend: PhxBlogger.Web.Gettext,",
          ~s/theme: "admin_lte",/,
          "web_namespace: Web,",
          "schema_adapter: Talon.Schema.Adapters.Ecto"
        ]

        assert_file "lib/phx_blogger/web/talon_web.ex", [
          "import PhxBlogger.Web.Router.Helpers",
          "import PhxBlogger.Web.ErrorHelpers",
          "import PhxBlogger.Web.Gettext",
        ]

        assert_file "lib/phx_blogger/web/controllers/talon/talon_resource_controller.ex", [
          "defmodule PhxBlogger.Web.TalonResourceController do",
          "use PhxBlogger.Web, :controller",
          "use Talon.Controller, repo: PhxBlogger.Repo, context: PhxBlogger.Talon"
        ]

        assert_file "lib/phx_blogger/web/talon_messages.ex", [
          "defmodule PhxBlogger.Web.Talon.Messages do",
          "import PhxBlogger.Web.Gettext"
        ]

        #########
        # Views

        assert_file "lib/phx_blogger/web/views/talon/admin_lte/layout_view.ex", [
          "defmodule AdminLte.Web.LayoutView do",
          ~s/use Talon.Web, which: :view, theme: "admin_lte", module: AdminLte.Web/
        ]

        assert_file "lib/phx_blogger/web/views/talon/admin_lte/components/datatable_view.ex", [
          "defmodule AdminLte.Web.DatatableView do",
          ~s/use Talon.Web, which: :component_view, theme: "admin_lte", module: AdminLte.Web/,
          "use Talon.Components.Datatable, __MODULE__"
        ]

        assert_file "lib/phx_blogger/web/views/talon/admin_lte/components/paginate_view.ex", [
          "defmodule AdminLte.Web.PaginateView do",
          ~s/use Talon.Web, which: :component_view, theme: "admin_lte", module: AdminLte.Web/
        ]

        #########
        # templates

        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/generators/edit.html.eex"
        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/generators/form.html.eex"
        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/generators/index.html.eex", [
          "= AdminLte.Web.DatatableView.render_table(@conn, @resources)"
        ]
        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/generators/new.html.eex"
        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/generators/show.html.eex"

        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/components/datatable/datatable.html.slim", [
          "= AdminLte.Web.PaginateView.paginate(@conn)"
        ]
        assert_file "lib/phx_blogger/web/templates/talon/admin_lte/components/datatable/table_body.html.slim"
        for file <- ~w(app nav_action_link nav_resource_link sidebar) do
          assert_file "lib/phx_blogger/web/templates/talon/admin_lte/layout/#{file}.html.slim"
        end
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

        assert_file "lib/blogger/talon/talon.ex", fn file ->
          assert file =~ "defmodule Blogger.Talon do"
          assert file =~ "use Talon, otp_app: :blogger"
        end

        assert_file "config/talon.exs", [
          "config :talon,",
          "module: Blogger,",
          "essages_backend: Blogger.Gettext,",
          ~s/theme: "admin_lte",/,
          "schema_adapter: Talon.Schema.Adapters.Ecto"
        ]

        assert_file "web/talon_web.ex", [
          "import Blogger.Router.Helpers",
          "import Blogger.ErrorHelpers",
          "import Blogger.Gettext",
        ]

        assert_file "web/controllers/talon/talon_resource_controller.ex", [
          "defmodule Blogger.TalonResourceController do",
          "use Blogger.Web, :controller",
          "use Talon.Controller, repo: Blogger.Repo, context: Blogger.Talon"
        ]

        assert_file "web/talon_messages.ex", [
          "defmodule Blogger.Talon.Messages do",
          "import Blogger.Gettext"
        ]

        assert_file "web/views/talon/admin_lte/layout_view.ex", [
          "defmodule AdminLte.LayoutView do",
          ~s/use Talon.Web, which: :view, theme: "admin_lte", module: AdminLte/
        ]

        assert_file "web/views/talon/admin_lte/components/datatable_view.ex", [
          "defmodule AdminLte.DatatableView do",
          ~s/use Talon.Web, which: :component_view, theme: "admin_lte", module: AdminLte/,
          "use Talon.Components.Datatable, __MODULE__"
        ]

        assert_file "web/views/talon/admin_lte/components/paginate_view.ex", [
          "defmodule AdminLte.PaginateView do",
          ~s/use Talon.Web, which: :component_view, theme: "admin_lte", module: AdminLte/
        ]

        #########
        # templates

        assert_file "web/templates/talon/admin_lte/generators/edit.html.eex"
        assert_file "web/templates/talon/admin_lte/generators/form.html.eex"
        assert_file "web/templates/talon/admin_lte/generators/index.html.eex", [
          "= AdminLte.DatatableView.render_table(@conn, @resources)"
        ]
        assert_file "web/templates/talon/admin_lte/generators/new.html.eex"
        assert_file "web/templates/talon/admin_lte/generators/show.html.eex"
        assert_file "web/templates/talon/admin_lte/components/datatable/datatable.html.slim", [
          "= AdminLte.PaginateView.paginate(@conn)"
        ]
        assert_file "web/templates/talon/admin_lte/components/datatable/table_body.html.slim"
        for file <- ~w(app nav_action_link nav_resource_link sidebar) do
          assert_file "web/templates/talon/admin_lte/layout/#{file}.html.slim"
        end
      end
    end
  end

  #################
  # Helpers

end
