defmodule Groq.Sender do
  @moduledoc false

  use GenServer

  alias Groq.{Request, SenderPool}

  @registry Groq.SenderRegistry

  ## API

  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts) when is_list(opts) do
    idx = Keyword.fetch!(opts, :index)
    GenServer.start_link(__MODULE__, [], name: {:via, Registry, {@registry, idx}})
  end

  @spec send_request(GenServer.server(), Request.t()) :: HTTPClient.response()
  def send_request(client, %Request{} = req) do
    random_index = Enum.random(1..SenderPool.pool_size())
    GenServer.call({:via, Registry, {@registry, random_index}}, {:send, client, req})
  end

  ## State

  defstruct []

  ## Callbacks

  @impl GenServer
  def init(_opts) do
    {:ok, %__MODULE__{}}
  end

  @impl GenServer
  def handle_call({:send, client, %Request{} = req}, _from, %__MODULE__{} = state) do
    resp = do_request(client, req)

    {:reply, resp, state}
  end

  ## Helpers

  defp do_request(client, %Request{} = req) do
    client.post(req.url, req.headers, req.body)
  end
end
