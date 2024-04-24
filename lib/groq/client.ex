defmodule Groq.Client do
  alias Groq.{Config, HTTPClient, Request, Sender}

  @spec post(
          url :: String.t(),
          headers :: HTTPClient.headers(),
          body :: HTTPClient.body(),
          opts :: Keyword.t()
        ) :: HTTPClient.response()
  def post(url, headers, body, opts \\ []) do
    base_url = Keyword.get_lazy(opts, :base_url, &Config.base_url/0)
    client = Keyword.get_lazy(opts, :client, &Config.client/0)
    api_key = Keyword.get_lazy(opts, :api_key, &Config.api_key/0)
    json_library = Keyword.get_lazy(opts, :json_library, &Config.json_library/0)

    req_headers =
      [{"authorization", "Bearer #{api_key}"}, {"content-type", "application/json"}] ++ headers

    req = %Request{
      url: "#{base_url}#{url}",
      headers: req_headers,
      body: json_library.encode!(body)
    }

    Sender.send_request(client, req)
  end
end
