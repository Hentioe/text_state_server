defmodule TextStateServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {TextStateServer.Task, state_file: "files/config.txt"},
      {TextStateServer.MessageReceiver, port: 21_337}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TextStateServer.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
