ExUnit.start()

alias Ecto.Integration.TestRepo

Application.put_env(:ecto, TestRepo,
  adapter: Ecto.Adapters.Postgres,
  url: "ecto://postgres:postgres@localhost/ecto_test",
  pool: Ecto.Adapters.SQL.Sandbox)

Application.put_env(:ectophile, :otp_app, :ectophile)

defmodule Ecto.Integration.TestRepo do
  use Ecto.Repo, otp_app: :ecto

  def log(_cmd), do: nil
end

# Load up the repository, start it, and run migrations
_   = Ecto.Storage.down(TestRepo)
:ok = Ecto.Storage.up(TestRepo)

{:ok, _pid} = TestRepo.start_link

Code.require_file "ecto_migration.exs", __DIR__

:ok = Ecto.Migrator.up(TestRepo, 0, Ecto.Integration.Migration, log: false)
Process.flag(:trap_exit, true)
