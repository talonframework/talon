Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.Gen.ComponentsTest do
  use ExUnit.Case
  import MixHelper

  alias Mix.Tasks.Talon.Gen.Components, as: GenComponents
  alias Mix.Tasks.Talon.New, as: GenNew

  @app_name "phx_blogger"

  setup do
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    {:ok, parsed: ~w(admin-lte admin-lte)}
  end

  describe "phx 1.3 structure" do
    test "new_1.3 defaults" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "component_phx_blogger_defaults", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "component_phx_blogger_defaults/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run ["--no-theme"] #{ }~w(--phx)
        Mix.Task.clear
        GenComponents.run []

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/components/datatable_view.ex", fn file ->
          assert file =~ ~s(defmodule PhxBlogger.Admin.AdminLte.Web.DatatableView do)
          assert file =~ ~s(use PhxBlogger.Talon.Web, which: :component_view, theme: "admin-lte", module: PhxBlogger.Admin.AdminLte.Web)
          assert file =~ ~s(use Talon.Components.Datatable, __MODULE__)
        end

        assert_file "lib/phx_blogger/talon/views/admin/admin-lte/components/paginate_view.ex", fn file ->
          assert file =~ ~s(defmodule PhxBlogger.Admin.AdminLte.Web.PaginateView do)
          assert file =~ ~s(use PhxBlogger.Talon.Web, which: :component_view, theme: "admin-lte", module: PhxBlogger.Admin.AdminLte.Web)
        end

        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= PhxBlogger.Admin.AdminLte.Web.PaginateView.paginate)
        end

        assert_file "lib/phx_blogger/talon/templates/admin/admin-lte/components/datatable/table_body.html.slim"

        Mix.Task.clear
        GenComponents.run ["--theme-name=admin-lte", "--target-theme=my-theme", "--concern=Main"]

        assert_file "lib/phx_blogger/talon/views/main/my-theme/components/datatable_view.ex", fn file ->
          assert file =~ ~s(defmodule PhxBlogger.Main.MyTheme.Web.DatatableView do)
          assert file =~ ~s(use PhxBlogger.Talon.Web, which: :component_view, theme: "my-theme", module: PhxBlogger.Main.MyTheme.Web)
          assert file =~ ~s(use Talon.Components.Datatable, __MODULE__)
        end

        assert_file "lib/phx_blogger/talon/views/main/my-theme/components/paginate_view.ex", fn file ->
          assert file =~ ~s(defmodule PhxBlogger.Main.MyTheme.Web.PaginateView do)
          assert file =~ ~s(use PhxBlogger.Talon.Web, which: :component_view, theme: "my-theme", module: PhxBlogger.Main.MyTheme.Web)
        end

        assert_file "lib/phx_blogger/talon/templates/main/my-theme/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= PhxBlogger.Main.MyTheme.Web.PaginateView.paginate)
        end

        assert_file "lib/phx_blogger/talon/templates/main/my-theme/components/datatable/table_body.html.slim"
      end
    end

    test "new_1.3 web path" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "component_phx_blogger_web_path", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "component_phx_blogger_web_path/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run ["--no-theme"] #{ }~w(--phx)
        Mix.Task.clear
        GenComponents.run ["--root-path=lib/phx_blogger/web", "--path-prefix=talon"]

        assert_file "lib/phx_blogger/web/views/talon/admin/admin-lte/components/datatable_view.ex", fn file ->
          assert file =~ ~s(defmodule PhxBlogger.Admin.AdminLte.Web.DatatableView do)
          assert file =~ ~s(use PhxBlogger.Talon.Web, which: :component_view, theme: "admin-lte", module: PhxBlogger.Admin.AdminLte.Web)
          assert file =~ ~s(use Talon.Components.Datatable, __MODULE__)
        end

        assert_file "lib/phx_blogger/web/views/talon/admin/admin-lte/components/paginate_view.ex", fn file ->
          assert file =~ ~s(defmodule PhxBlogger.Admin.AdminLte.Web.PaginateView do)
          assert file =~ ~s(use PhxBlogger.Talon.Web, which: :component_view, theme: "admin-lte", module: PhxBlogger.Admin.AdminLte.Web)
        end

        assert_file "lib/phx_blogger/web/templates/talon/admin/admin-lte/components/datatable/datatable.html.slim", fn file ->
          assert file =~ ~s(= PhxBlogger.Admin.AdminLte.Web.PaginateView.paginate)
        end

        assert_file "lib/phx_blogger/web/templates/talon/admin/admin-lte/components/datatable/table_body.html.slim"
      end
    end
  end
end
