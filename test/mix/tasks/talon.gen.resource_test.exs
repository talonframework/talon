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

    test "create resource task" do
      Logger.disable(self())

      Application.put_env(:phx_blogger, PhxBlogger.Web.Endpoint,
        secret_key_base: String.duplicate("abcdefgh", 8),
        code_reloader: true,
        root: File.cwd!)

      in_tmp "create_resource_task", fn ->
        Mix.Tasks.Phx.New.run([@app_name, "--no-ecto"])
      end

      in_project :phx_blogger, Path.join(tmp_path(), "create_resource_task/phx_blogger"), fn _ ->
        Mix.Task.clear
        GenNew.run [] #{ }~w(--phx)

        Mix.Task.clear
        GenResource.run ["Blogs.Post"]
        concern_path = Path.join(["lib", "phx_blogger", "talon", "admin"])

        assert_file Path.join(concern_path, "post.ex"), fn file ->
          assert file =~ "defmodule PhxBlogger.Admin.Blogs.Post do"
          assert file =~ "use Talon.Resource, schema: PhxBlogger.Blogs.Post, concern: PhxBlogger.Admin"
        end
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
