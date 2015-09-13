defmodule Ecto.Integration.Migration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar, :jsonb
    end
  end
end
