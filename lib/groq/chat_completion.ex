defmodule Groq.ChatCompletion do
  alias Groq.{Client, Config}

  @type function_call :: %{
          name: String.t(),
          arguments: String.t()
        }

  @type tool_call :: %{
          id: binary(),
          type: String.t(),
          function: function_call()
        }

  @type choice_message :: %{
          content: String.t() | nil,
          tool_calls: [tool_call()],
          role: String.t()
        }

  @type logprob :: %{
          token: String.t(),
          logprob: float(),
          bytes: [integer()]
        }

  @type choice_logprobs_content :: %{
          token: String.t(),
          logprob: float(),
          bytes: [integer()],
          top_logprobs: [logprob()]
        }

  @type choice_logprobs :: %{
          content: [choice_logprobs_content()]
        }

  @type choice :: %{
          finish_reason: String.t() | nil,
          index: pos_integer(),
          message: choice_message(),
          logprobs: choice_logprobs() | nil
        }

  @type usage :: %{
          completion_tokens: pos_integer(),
          prompt_tokens: pos_integer(),
          total_tokens: pos_integer()
        }

  @type t :: %__MODULE__{
          id: String.t(),
          choices: [choice()],
          created: pos_integer(),
          model: String.t(),
          system_fingerprint: String.t(),
          usage: usage()
        }

  @type response_mode_opts :: %{
          required(:type) => String.t()
        }

  @type message :: %{
          required(:role) => String.t(),
          required(:content) => String.t(),
          optional(:name) => String.t(),
          optional(:seed) => binary() | integer()
        }

  @type params :: %{
          required(:model) => String.t(),
          required(:messages) => [message()],
          optional(:temperature) => float(),
          optional(:max_tokens) => integer(),
          optional(:top_p) => float(),
          optional(:stream) => boolean(),
          optional(:stop) => binary(),
          optional(:response_format) => response_mode_opts()
        }

  defstruct [:id, :choices, :created, :model, :system_fingerprint, :usage]

  @create_endpoint "/v1/chat/completions"

  # @spec create(req_params :: params(), opts :: Keyword.t()) :: HTTPClient.response()
  def create(req_params, opts \\ []) do
    @create_endpoint
    |> Client.post([], req_params, opts)
    |> handle_response()
  end

  defp handle_response({:ok, status, _headers, body}) do
    json_library = Config.json_library()
    json = json_library.decode!(body)

    if status < 400 do
      {:ok, json}
    else
      {:error, json}
    end
  end
end
