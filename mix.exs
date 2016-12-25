defmodule CrawlieExample.Mixfile do
  use Mix.Project

  def project do
    [
      app: :crawlie_example,
      version: "0.2.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :crawlie]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:crawlie, "~> 0.2.0"},
      # {:crawlie, git: "https://github.com/nietaki/crawlie.git", branch: "master"},
      {:floki, "~> 0.11.0"}, # for HTML parsing
    ]
  end
end
