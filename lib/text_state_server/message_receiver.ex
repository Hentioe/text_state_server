defmodule TextStateServer.MessageReceiver do
  @moduledoc false

  use GenServer

  alias TextStateServer.Task

  require Logger

  def start_link(opts) do
    port = Keyword.get(opts, :port)

    GenServer.start_link(__MODULE__, %{port: port}, name: __MODULE__)
  end

  @impl true
  def init(%{port: port} = state) do
    {:ok, socket} = :gen_udp.open(port)

    {:ok, Map.put(state, :socket, socket)}
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    packet = data |> to_string() |> String.trim()

    case parse_packet(packet) do
      :parsing_failed ->
        Logger.warn("Unknown packet: `#{packet}`")

      :unknown_cnt ->
        Logger.warn("Unknown cnt packet: `#{packet}`")

      {user, message} ->
        Task.dispatch(user, {socket, {ip, port}}, message)
    end

    {:noreply, state}
  end

  defp parse_packet(<<"v1", no::binary-size(1), msg::binary>> = _data) do
    try do
      cnt = String.to_existing_atom("cnt#{no}")

      {cnt, msg}
    rescue
      ArgumentError ->
        :unknown_cnt
    end
  end

  defp parse_packet(_data) do
    :parsing_failed
  end
end
