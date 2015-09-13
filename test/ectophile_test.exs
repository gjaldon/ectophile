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
      |> cast(params, ~w(), ~w(avatar_upload))
    end
  end

  setup do
    ensure_upload_paths_exist(User)

    on_exit fn ->
      File.rm_rf Path.expand "../priv/", __DIR__
    end
    :ok
  end

  test "uploads file on insert" do
    params = %{avatar_upload: fake_upload()}
    user = TestRepo.insert! User.changeset(%User{}, params)

    assert user.avatar
    assert user.avatar_filename == params.avatar_upload.filename
    assert File.exists? Path.expand(".." <> user.avatar, __DIR__)
  end

  test "uploads file on update" do
    user = TestRepo.insert! %User{}
    params = %{avatar_upload: fake_upload()}
    user = TestRepo.update! User.changeset(user, params)

    assert user.avatar
    assert user.avatar_filename == params.avatar_upload.filename
    assert File.exists? Path.expand(".." <> user.avatar, __DIR__)
  end

  test "removes old file on update" do
    params = %{avatar_upload: fake_upload()}
    user = User.changeset(%User{}, params)
           |> TestRepo.insert!
           |> Map.put(:avatar_upload, nil)
    TestRepo.update! User.changeset(user, params)

    refute File.exists? Path.expand(".." <> user.avatar, __DIR__)
  end

  test "removes file on delete" do
    params = %{avatar_upload: fake_upload()}
    user = User.changeset(%User{}, params) |> TestRepo.insert!

    TestRepo.delete! user

    refute File.exists? Path.expand(".." <> user.avatar, __DIR__)
  end
end
