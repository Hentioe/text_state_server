defmodule TextStateServer.Task do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(opts) do
    state_file = Keyword.get(opts, :state_file)

    GenServer.start_link(__MODULE__, %{state_file: state_file}, name: __MODULE__)
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
  def handle_cast({_user, _source, message}, state)
      when message in ["client1", "client2", "client3"] do
    Logger.debug("Heartbeat from #{message}")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt2, _source, "client2|NULL"}, %{state_file: state_file} = state) do
    overwrite_id2(state_file, "null")
    write_tmp2("null")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt2, _source, <<"client2|" <> info>>}, %{state_file: state_file} = state) do
    overwrite_id2(state_file, "null")
    write_tmp2(info)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt3, _source, "client3|NULL"}, %{state_file: state_file} = state) do
    overwrite_id3(state_file, "null")
    write_tmp3("null")

    {:noreply, state}
  end

  @impl true
  def handle_cast({:cnt3, _source, "client3|INFO"}, %{state_file: state_file} = state) do
    overwrite_id3(state_file, "null")
    write_tmp3("INFO")

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

  @spec write_tmp2(iodata) :: :ok
  defp write_tmp2(iodata) do
    path = "/" |> Path.join("tmp") |> Path.join("2.txt")

    File.write!(path, iodata)
  end

  @spec write_tmp3(iodata) :: :ok
  defp write_tmp3(iodata) do
    path = "/" |> Path.join("tmp") |> Path.join("3.txt")

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
