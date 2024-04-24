defmodule Groq.SenderPool do
  @moduledoc false

  use Supervisor

  alias Groq.Config

  @spec start_link(opts :: Keyword.t()) :: Supervisor.on_start()
  def start_link(opts) when is_list(opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children =
      for idx <- 1..pool_size() do
        Supervisor.child_spec({Groq.Sender, [index: idx]}, id: {Groq.Sender, idx})
      end

    Supervisor.init(children, strategy: :one_for_one)
  end

  def pool_size, do: Config.pool_size()
end
