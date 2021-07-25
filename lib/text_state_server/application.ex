defmodule TextStateServer.Application do
  @moduledoc false

  use Application

  alias TextStateServer.{PathNotExist, PathPermissionsError}

  def start(_type, _args) do
    # TODO：添加文件是否存在、权限相关的检查。

    state_file = file_check!(:state_file, [:read_write, :write])
    tmp_file2 = file_check!(:tmp_file2, [:read_write, :write], check_dir: true)
    tmp_file3 = file_check!(:tmp_file3, [:read_write, :write], check_dir: true)

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

  # 检查状态文件是否存在以及权限是否合理。
  # 存在问题将直接抛出异常，否则返回状态文件配置的值（即路径）。
  defp file_check!(file_key, accesses, opts \\ []) do
    check_dir? = Keyword.get(opts, :check_dir, false)

    file = Application.get_env(:text_state_server, file_key)

    path =
      if check_dir? do
        Path.dirname(file)
      else
        file
      end

    case :file.read_file_info(String.to_charlist(path)) do
      {:ok, file_info} ->
        access = elem(file_info, 3)

        if access in accesses do
          file
        else
          Kernel.raise(
            PathPermissionsError,
            "Path `#{path}` does not satisfy `#{Enum.join(accesses, " or ")}` permissions"
          )
        end

      {:error, :enoent} ->
        Kernel.raise(PathNotExist, "No `#{path}` directory")
    end
  end
end
