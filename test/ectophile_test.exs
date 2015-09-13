defmodule EctophileTest do
  use ExUnit.Case

  alias Ecto.Integration.TestRepo
  import Ectophile.Helpers

  def fake_upload do
    %Plug.Upload{filename: "test", path: Path.expand("./test/fixtures/test.jpg")}
  end

  defmodule User do
    use Ectophile
    use Ecto.Model

    schema "users" do
      attachment_fields :avatar
    end

    def changeset(model, params \\ :empty) do
      model
      |> cast(params, ~w(avatar_upload), ~w())
    end
  end

  setup do
    ensure_upload_paths_exist(User)

    on_exit fn ->
      File.rm_rf Path.expand "../priv/static/avatar"
    end
    :ok
  end

  test "uploads file on insert" do
    params = %{avatar_upload: fake_upload()}
    user = TestRepo.insert! User.changeset(%User{}, params)

    IO.inspect user
    assert user.avatar
    assert File.exists? user.avatar
  end
end
