defmodule Groq.Request do
  @moduledoc false

  defstruct [:url, :body, headers: []]
end
