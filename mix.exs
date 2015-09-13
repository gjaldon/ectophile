defmodule Ectophile.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :ectophile,
     version: @version,
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: "File upload extension for Ecto",
     package: package,
     name: "Ectophile",
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/gjaldon/ectophile"]]
  end

  defp package do
    [contributors: ["Gabriel Jaldon"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/gjaldon/ectophile"},
     files: ~w(mix.exs README.md lib)]
  end

  def application do
    [applications: [:logger, :ecto]]
  end

  defp deps do
    [{:ecto, "~> 1.0"},
     {:postgrex, "~> 0.9.1", optional: true},
     {:mariaex, "~> 0.4.1", optional: true},
     {:plug, "~> 1.0", only: :test},
     {:ex_doc, "~> 0.7", only: :docs},
     {:earmark, "~> 0.1", only: :docs},
     {:inch_ex, only: :docs}]
  end
end
