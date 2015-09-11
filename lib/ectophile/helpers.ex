defmodule Ectophile.Helpers do

  def static_path(filepath) do
    "/" <> Path.relative_to(filepath, "/priv/static")
  end

  def ensure_upload_paths_exist(mod) when is_atom(mod) do
    mod.ensure_upload_paths_exist()
  end

  def ensure_upload_paths_exist(mods) when is_list(mods) do
    Enum.each mods, &(&1.ensure_upload_paths_exist())
  end
end
