defmodule TextStateServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # TODO：添加文件是否存在、权限相关的检查。

    state_file = Application.get_env(:text_state_server, :state_file)
    tmp_file2 = Application.get_env(:text_state_server, :tmp_file2)
    tmp_file3 = Application.get_env(:text_state_server, :tmp_file3)
    port = Application.get_env(:text_state_server, :port)

    task_opts = [
      state_file: state_file,
      tmp_file2: tmp_file2,
      tmp_file3: tmp_file3
    ]

    message_recevier_opts = [port: port]

    children = [
      {TextStateServer.Task, task_opts},
      {TextStateServer.MessageReceiver, message_recevier_opts}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TextStateServer.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
