defmodule Groq.Config do
  @moduledoc false
  # Code in this module is heavy borrowed from the wonderful Sentry elixir library.
  # https://github.com/getsentry/sentry-elixir/blob/master/lib/sentry/config.ex

  opts_schema = [
    base_url: [
      type: :string,
      required: false,
      default: "https://api.groq.com/openai",
      doc: "The base URL for the Groq Cloud API."
    ],
    api_key: [
      type: :string,
      required: true,
      default: nil,
      doc: "The API key for the Groq Cloud API."
    ],
    client: [
      type: :atom,
      type_doc: "`t:module/0`",
      default: Groq.HackneyClient,
      doc: """
      A module that implements the `Groq.HTTPClient`
      behaviour. Defaults to `Groq.HackneyClient`, which uses
      [hackney](https://github.com/benoitc/hackney) as the HTTP client.
      """
    ],
    hackney_opts: [
      type: :keyword_list,
      default: [pool: :sentry_pool],
      doc: """
      Options to be passed to `hackney`. Only
      applied if `:client` is set to `Groq.HackneyClient`.
      """
    ],
    hackney_pool_timeout: [
      type: :timeout,
      default: 5000,
      doc: """
      The maximum time to wait for a
      connection to become available. Only applied if `:client` is set to
      `Groq.HackneyClient`.
      """
    ],
    hackney_pool_max_connections: [
      type: :pos_integer,
      default: 50,
      doc: """
      The maximum number of
      connections to keep in the pool. Only applied if `:client` is set to
      `Groq.HackneyClient`.
      """
    ],
    json_library: [
      type: {:custom, __MODULE__, :__validate_json_library__, []},
      default: Jason,
      type_doc: "`t:module/0`",
      doc: """
      A module that implements the "standard" Elixir JSON behaviour, that is, exports the
      `encode/1` and `decode/1` functions. If you use the default, make sure to add
      [`:jason`](https://hex.pm/packages/jason) as a dependency of your application.
      """
    ],
    pool_size: [
      type: :pos_integer,
      default: 10,
      doc: """
      The maximum number of connections to keep in the client pool.
      """
    ]
  ]

  @opts_schema NimbleOptions.new!(opts_schema)
  @valid_keys Keyword.keys(opts_schema)

  @spec validate!() :: Keyword.t()
  def validate! do
    :groq
    |> Application.get_all_env()
    |> validate!()
  end

  @spec validate!(config :: Keyword.t()) :: Keyword.t()
  def validate!(config) do
    opts =
      config
      |> Keyword.take(@valid_keys)
      |> load_from_env(:base_url, "GROQ_BASE_URL")
      |> load_from_env(:api_key, "GROQ_API_KEY")

    case NimbleOptions.validate(opts, @opts_schema) do
      {:ok, validated_opts} ->
        validated_opts

      {:error, error} ->
        raise ArgumentError, """
        invalid configuration for the :groq application. The error was:

            #{Exception.message(error)}

        See the documentation for the Groq module for more information on configuration.
        """
    end
  end

  @spec load_from_env(config :: Keyword.t(), config_key :: atom(), env_key :: String.t()) ::
          Keyword.t()
  def load_from_env(config, config_key, env_key) do
    if System.get_env(env_key) do
      Keyword.put(config, config_key, System.get_env(env_key))
    else
      config
    end
  end

  @spec persist(config :: Keyword.t()) :: :ok
  def persist(config) when is_list(config) do
    Enum.each(config, fn {key, value} ->
      :persistent_term.put({:groq_config, key}, value)
    end)
  end

  @spec client() :: module()
  def client, do: get(:client)

  @spec hackney_opts() :: Keyword.t()
  def hackney_opts, do: fetch!(:hackney_opts)

  @spec json_library() :: module()
  def json_library, do: fetch!(:json_library)

  @spec base_url() :: String.t()
  def base_url, do: get(:base_url)

  @spec api_key() :: binary()
  def api_key, do: fetch!(:api_key)

  @spec max_hackney_connections() :: pos_integer()
  def max_hackney_connections, do: fetch!(:hackney_pool_max_connections)

  @spec hackney_timeout() :: timeout()
  def hackney_timeout, do: fetch!(:hackney_pool_timeout)

  @spec pool_size() :: pos_integer()
  def pool_size, do: fetch!(:pool_size)

  @compile {:inline, fetch!: 1}
  defp fetch!(key) do
    :persistent_term.get({:groq_config, key})
  rescue
    ArgumentError ->
      raise """
      the Groq configuration seems to be not available (while trying to fetch \
      #{inspect(key)}). This is likely because the :groq application has not been started yet. \
      Make sure that you start the :groq application before using any of its functions.
      """
  end

  @compile {:inline, fetch!: 1}
  defp get(key) do
    :persistent_term.get({:groq_config, key}, nil)
  end

  def __validate_json_library__(nil) do
    {:error, "nil is not a valid value for the :json_library option"}
  end

  def __validate_json_library__(mod) when is_atom(mod) do
    try do
      with {:ok, %{}} <- mod.decode("{}"),
           {:ok, "{}"} <- mod.encode(%{}) do
        {:ok, mod}
      else
        _ ->
          {:error,
           "configured :json_library #{inspect(mod)} does not implement decode/1 and encode/1"}
      end
    rescue
      UndefinedFunctionError ->
        {:error,
         """
         configured :json_library #{inspect(mod)} is not available or does not implement decode/1 and encode/1.
         Do you need to add #{inspect(mod)} to your mix.exs?
         """}
    end
  end

  def __validate_json_library__(other) do
    {:error, "expected :json_library to be a module, got: #{inspect(other)}"}
  end
end
