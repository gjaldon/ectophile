defmodule Ectophile.Helpers do

  def static_path(filepath) do
    "/" <> Path.relative_to(filepath, "/priv/static")
  end

  def ensure_upload_paths_exist(mod) when is_atom(mod) do
    ectophile_data = mod.__ectophile_data__()
    for %{upload_path: upload_path} <- ectophile_data do
      priv_path = Ectophile.priv_path(upload_path)
      build_priv_path = Ectophile.build_priv_path(upload_path)

      unless File.exists?(priv_path) do
        File.mkdir_p!(priv_path)
      end

      unless File.exists?(build_priv_path) do
        File.mkdir_p!(build_priv_path)
      end
    end
  end

  def ensure_upload_paths_exist(mods) when is_list(mods) do
    Enum.each(mods, &ensure_upload_paths_exist/1)
  end
end
