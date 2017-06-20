Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.Gen.ResourceTest do
  use ExUnit.Case
  import MixHelper

  alias Mix.Tasks.Talon.Gen.Resource, as: GenResource
  alias Mix.Tasks.Talon.New, as: GenNew

  @app_name "phx_blogger"

  setup do
    send self(), {:mix_shell_input, :yes?, false}
    send self(), {:mix_shell_input, :yes?, false}
    :ok
  end

  describe "phx 1.3 structure" do

    test "create resource defaults" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "create_resource_defaults", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "create_resource_defaults/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run [] #{ }~w(--phx)

        Mix.Task.clear
        GenResource.run ["Blogs.Post"]
        root_path = Path.join(["lib", "phx_blogger", "talon"])
        concern_path = Path.join([root_path, "admin"])
        view_path = Path.join([root_path, "views", "admin", "admin-lte"])

        assert_file Path.join(concern_path, "post.ex"), [
          "defmodule PhxBlogger.Admin.Blogs.Post do",
          "use Talon.Resource, schema: PhxBlogger.Blogs.Post, concern: PhxBlogger.Admin"
        ]
        assert_file Path.join(view_path, "post_view.ex"), [
          "defmodule PhxBlogger.Admin.AdminLte.Web.PostView do",
          ~s{use PhxBlogger.Talon.Web, which: :view, theme: "admin/admin-lte", module: PhxBlogger.Admin.AdminLte.Web}
        ]
      end
    end

    test "create resource theme and concern" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "create_resource_theme_concern", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "create_resource_theme_concern/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run [] #{ }~w(--phx)

        Mix.Task.clear
        GenResource.run ["Blogs.Post", "--target-theme=front-end", "--concern=Front"]
        root_path = Path.join(["lib", "phx_blogger", "talon"])
        concern_path = Path.join([root_path, "front"])
        view_path = Path.join([root_path, "views", "front", "front-end"])


        assert_file Path.join(concern_path, "post.ex"), [
          "defmodule PhxBlogger.Front.Blogs.Post do",
          "use Talon.Resource, schema: PhxBlogger.Blogs.Post, concern: PhxBlogger.Front"
        ]

        assert_file Path.join(view_path, "post_view.ex"), [
          "defmodule PhxBlogger.Front.FrontEnd.Web.PostView do",
          ~s{use PhxBlogger.Talon.Web, which: :view, theme: "front/front-end", module: PhxBlogger.Front.FrontEnd.Web}
        ]
      end
    end
  end

  describe "phoenix structure" do
    test "create resource phoenix" do
      Logger.disable(self())

      Application.put_env(:blogger, Blogger.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "create_resource_phoenix", fn ->
        Mix.Tasks.Phoenix.New.run(["blogger", "--no-ecto"])
      end

      in_project :blogger, Path.join(tmp_path(), "create_resource_phoenix/blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run [] #{ }~w(--phx)

        Mix.Task.clear
        GenResource.run ["Post"]
        concern_path = Path.join(["lib", "blogger", "talon", "admin"])

        assert_file Path.join(concern_path, "post.ex"), fn file ->
          assert file =~ "defmodule Blogger.Admin.Post do"
          assert file =~ "use Talon.Resource, schema: Blogger.Post, concern: Blogger.Admin"
        end
        assert_file "lib/blogger/talon/views/admin/admin-lte/post_view.ex", fn file ->
          assert file =~ "defmodule Blogger.Admin.AdminLte.PostView do"
        end
      end
    end

  end
end
