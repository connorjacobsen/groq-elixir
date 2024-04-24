defmodule Groq.HTTPClient do
  @moduledoc """
  HTTP client behaviour.
  """

  @typedoc """
  The response status for an HTTP request.
  """
  @type status :: 100..599

  @typedoc """
  The headers for an HTTP request or response.
  """
  @type headers :: [{String.t(), String.t()}]

  @typedoc """
  The body for an HTTP request or response.
  """
  @type body :: binary()

  @typedoc """
  The response for an HTTP request.
  """
  @type response :: {:ok, status(), headers(), body()} | {:error, term()}

  @doc """
  Make an HTTP POST request to the given `url` with the provided `req_headers` and `req_body`.
  """
  @callback post(url :: String.t(), req_headers :: headers(), req_body :: body()) :: response()
end
