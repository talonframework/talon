Code.require_file "../../mix_helpers.exs", __DIR__

defmodule Mix.Tasks.Talon.NewTest do
  use ExUnit.Case
  import MixHelper
  import Talon.TestHelpers

  alias Mix.Tasks.Talon.New, as: GenNew

  setup do
    {:ok, parsed: ~w(admin_lte admin_lte)}
  end

  describe "phx-1.3 structure" do
    test "add compiler", %{parsed: _parsed} do
      in_tmp "add_compiler", fn ->
        File.write "mix.exs", mix_exs()
        mk_phoenix_project()
        opts =
          (~w(brunch assets layouts generators components)
          |> Enum.map(& "--no-#{&1}"))

        GenNew.run opts ++ [~s(--web-path=web), "--phoenix"]

        assert_file "mix.exs", fn file ->
          assert file =~ "compilers: [:talon, :phoenix, :gettext] ++ Mix.compilers,"
        end
      end
    end
  end
  describe "phoenix structure" do
    test "add compiler", %{parsed: _parsed} do
      in_tmp "add_compiler_phoenix", fn ->
        File.write "mix.exs", mix_exs()
        mk_phx_project()
        opts =
          (~w(brunch assets layouts generators components)
          |> Enum.map(& "--no-#{&1}"))

        GenNew.run opts ++ ["--phx"]

        assert_file "mix.exs", fn file ->
          assert file =~ "compilers: [:talon, :phoenix, :gettext] ++ Mix.compilers,"
        end
      end
    end
  end

  #################
  # Helpers

end
