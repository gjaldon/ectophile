defmodule Ectophile.Type do
  @behaviour Ecto.Type

  def type, do: :map

  def cast(map) when is_map(map) do
    {:ok, validate_map(map)}
  end

  def cast(keyword) when is_list(keyword) do
    map = keyword
      |> Enum.into(%{})
      |> validate_map
    {:ok, map}
  end

  def cast({filename, filepath}) do
    {:ok, %{filename: filename, filepath: filepath}}
  end

  def cast(nil) do
    {:ok, nil}
  end

  def cast(_term) do
    :error
  end

  def load(map) when is_map(map) do
    {:ok, map}
  end

  def dump(map) when is_map(map) do
    {:ok, validate_map(map)}
  end

  def dump(_term) do
    :error
  end

  defp validate_map(map) do
    keys = map
      |> Map.keys()
      |> Enum.sort()
    if keys == [:filename, :filepath] do
      map
    else
      raise "must include `filename` and `filepath` keys"
    end
  end
end
