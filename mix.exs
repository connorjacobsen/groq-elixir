defmodule Groq.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/connorjacobsen/groq-elixir"

  def project do
    [
      app: :groq,
      name: "Groq",
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: "Elixir client for Groq API",
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Groq.Application, []},
      extra_applications: [:logger],
      registered: [
        Groq.SenderRegistry,
        Groq.Supervisor
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_options, "~> 1.1"},

      # Optional dependencies:
      {:hackney, "~> 1.8", optional: true},
      {:jason, "~> 1.1", optional: true},
      {:telemetry, "~> 0.4 or ~> 1.0", optional: true},

      # Development and Test dependencies:
      {:bypass, "~> 2.0", only: [:test]},
      {:dialyxir, "~> 1.0", only: [:test, :dev], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support"] ++ elixirc_paths(:dev)
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ["lib", "LICENSE", "mix.exs", "README.md"],
      maintainers: ["Connor Jacobsen"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
