defmodule Ecto.Integration.Migration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar, :string
      add :avatar_filename, :string
    end
  end
end
