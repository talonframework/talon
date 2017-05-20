ExUnit.start()

defmodule ExAdmin.RepoSetup do
  use ExUnit.CaseTemplate
end

TestExAdmin.Repo.__adapter__.storage_down TestExAdmin.Repo.config
TestExAdmin.Repo.__adapter__.storage_up TestExAdmin.Repo.config

{:ok, _pid} = TestExAdmin.Repo.start_link
{:ok, _pid} = TestExAdmin.Endpoint.start_link
_ = Ecto.Migrator.up(TestExAdmin.Repo, 0, TestExAdmin.Migrations, log: false)
Process.flag(:trap_exit, true)
Ecto.Adapters.SQL.Sandbox.mode(TestExAdmin.Repo, :manual)