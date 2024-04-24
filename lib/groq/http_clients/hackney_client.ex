defmodule Groq.HackneyClient do
  @behaviour Groq.HTTPClient

  @hackney_pool_name :groq_pool

  @impl true
  def post(url, headers, body) do
    hackney_opts =
      Groq.Config.hackney_opts()
      |> Keyword.put_new(:pool, @hackney_pool_name)

    case :hackney.request(:post, url, headers, body, [:with_body] ++ hackney_opts) do
      {:ok, _status, _headers, _opts} = result -> result
      {:error, _reason} = err -> err
    end
  end
end
