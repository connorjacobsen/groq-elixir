defmodule Groq.Application do
  @moduledoc false

  use Application

  alias Groq.Config

  @impl true
  def start(_type, _opts) do
    config = Config.validate!()
    :ok = Config.persist(config)

    children = [
      {Registry, keys: :unique, name: Groq.SenderRegistry},
      Groq.SenderPool
    ]

    with {:ok, pid} <-
           Supervisor.start_link(children, strategy: :one_for_one, name: Groq.Supervisor) do
      {:ok, pid}
    end
  end
end
