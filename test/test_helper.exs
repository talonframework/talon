ExUnit.start()

defmodule Talon.RepoSetup do
  use ExUnit.CaseTemplate
end

TestTalon.Repo.__adapter__.storage_down TestTalon.Repo.config
TestTalon.Repo.__adapter__.storage_up TestTalon.Repo.config

{:ok, _pid} = TestTalon.Repo.start_link
{:ok, _pid} = TestTalon.Endpoint.start_link
_ = Ecto.Migrator.up(TestTalon.Repo, 0, TestTalon.Migrations, log: false)
Process.flag(:trap_exit, true)
Ecto.Adapters.SQL.Sandbox.mode(TestTalon.Repo, :manual)
