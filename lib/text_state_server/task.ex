defmodule TextStateServer.Task do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(opts) do
    state_file = Keyword.get(opts, :state_file)
    tmp_file2 = Keyword.get(opts, :tmp_file2)
    tmp_file3 = Keyword.get(opts, :tmp_file3)

    state = %{state_file: state_file, tmp_file2: tmp_file2, tmp_file3: tmp_file3}

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @type client :: :cnt1 | :cnt2 | :cnt3
  @type source :: {:gen_udp.socket(), {:inet.ip_address(), :inet.port_number()}}

  @spec dispatch(client, source, binary) :: :ok
  def dispatch(user, source, message) do
    GenServer.cast(__MODULE__, {user, source, message})
  end

  @impl true
  def handle_cast({_user, source, "fetch"}, %{state_file: state_file} = state) do
    resp(source, File.read!(state_file))

    {:noreply, state}
  end

  @impl true
  def handle_cast({user, _source, "heartbeat"}, state) when user in [:cnt1, :cnt2, :cnt3] do
    Logger.debug("Heartbeat from #{user}")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt2, _source, "NULL"}, state) do
    %{state_file: state_file, tmp_file2: tmp_file2} = state

    overwrite_id2(state_file, "null")
    write(tmp_file2, "null")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt2, _source, info}, state) do
    %{state_file: state_file, tmp_file2: tmp_file2} = state

    overwrite_id2(state_file, "null")
    write(tmp_file2, info)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt3, _source, "NULL"}, state) do
    %{state_file: state_file, tmp_file3: tmp_file3} = state

    overwrite_id3(state_file, "null")
    write(tmp_file3, "null")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt3, _source, info}, state) do
    %{state_file: state_file, tmp_file3: tmp_file3} = state

    overwrite_id3(state_file, "null")
    write(tmp_file3, info)

    {:noreply, state}
  end

  @impl true
  def handle_cast({user, _source, message}, state) do
    Logger.warn("Ignored unknown message from #{user}: `#{message}`")

    {:noreply, state}
  end

  @spec resp(source, binary) :: :ok | {:error, any}
  defp resp(source, packet) do
    {socket, {ip, port}} = source

    :gen_udp.send(socket, ip, port, packet)
  end

  @spec write(Path.t(), iodata) :: :ok
  defp write(path, iodata) do
    File.write!(path, iodata)
  end

  @spec parse_state_content(Path.t()) :: [binary, ...]
  defp parse_state_content(state_file) do
    case state_file |> File.read!() |> String.trim() |> String.split("|") do
      [_id1, _id1_state, _id2, _id3] = state -> state
      _ -> ["null", "null", "null", "null"]
    end
  end

  @spec overwrite_id2(Path.t(), binary) :: :ok
  defp overwrite_id2(state_file, id2) do
    [id1, id1_state, _id2, id3] = parse_state_content(state_file)

    overwirte_state_content(state_file, [id1, id1_state, id2, id3])
  end

  @spec overwrite_id3(Path.t(), binary) :: :ok
  defp overwrite_id3(state_file, id3) do
    [id1, id1_state, id2, _id3] = parse_state_content(state_file)

    overwirte_state_content(state_file, [id1, id1_state, id2, id3])
  end

  @spec overwirte_state_content(Path.t(), [binary, ...]) :: :ok
  defp overwirte_state_content(state_file, [id1, id1_state, id2, id3]) do
    File.write!(state_file, "#{id1}|#{id1_state}|#{id2}|#{id3}")
  end
end
