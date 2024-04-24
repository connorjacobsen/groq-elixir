# Groq

Elixir client for the [Groq](https://www.groq.com) API.

_Note_: This client is usable but still has some rough edges. Please bare with me and feel free to open an issue or PR if you find any bugs or have any suggestions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `groq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:groq, "~> 0.1"},

    # Hackney is required to use the included HTTP adapter.
    {:hackey, "~> 0.1"},

    # Jason or an alternative JSON library is required to parse responses.
    {:jason, "~> 1.2"}
  ]
end
```

## Configuration

You can specify your API key via the `GROQ_API_KEY` environment variable or by passing it in your elixir configuration:

```elixir
config :groq, api_key: "your-api-key"
```

## Basic Usage

```elixir
Groq.ChatCompletion.create(%{
  "model" => "mixtral-8x7b-32768",
  "messages" => [
    %{
      "role" => "user",
      "content" => "Explain the importance of fast language models"
    }
  ]
})
```

## Development

If you load the application with `iex -S mix` for local testing, please note you will need to ensure that the `:hackey` application has started before you can make requests. You can do this by running `Application.ensure_all_started(:hackey)` in the iex shell.

## Credit and Thanks

This library was heavily inspired by the [Sentry](https://github.com/getsentry/sentry-elixir) Elixir SDK and borrows heavily from it.
