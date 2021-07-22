defmodule TextStateServer.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # TODO：添加文件是否存在、权限相关的检查。

    task_opts = [
      state_file: "files/config.txt",
      tmp_file2: "files/tmp_file2",
      tmp_file3: "files/tmp_file3"
    ]

    message_recevier_opts = [port: 21_337]

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
