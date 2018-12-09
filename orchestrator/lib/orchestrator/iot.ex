defmodule Orchestrator.Iot do
  @registry_addr :registry@localhost

  use GenServer

  def init(_), do: {:ok, %{}}

  def start_link(_) do
    Node.start(:orchestrator@localhost,:shortnames)
    Node.set_cookie(:secret)
    # Add to give atom as name, had issues when receiving from Python
    GenServer.start_link(__MODULE__, %{}, name: :orchestrator)
  end

  #Start a timer to send random messages
  def handle_call({:timer, ms}, _sender, state) do
    send(self(), {:timer, ms})
    {:reply, :tick, state}
  end

  # Gathers information from registry node
  def handle_call(:stats, _sender, state) do
    true = Node.connect(@registry_addr)
    send({:mailbox, @registry_addr}, {:stats})
    {:reply, :ok, state}
  end
  # Self message to send random string to IOT nodes
  def handle_info({:timer, ms}, state) do
    send(self(), {:msg, :crypto.strong_rand_bytes(30) |> Base.encode64()})
    Process.send_after(self(), {:timer, ms}, ms)
    {:noreply, state}
  end

  # Send message to IOT node
  def handle_info({:msg, message}, state) do
    {:ok, node} = connect_to_worker()
    send({:mailbox, node}, to_charlist(message))
    {:noreply, state}
  end

  # Receive message from Registry with stat
  def handle_info({:stats, content}, state) do
    IO.inspect Enum.group_by(content, fn {k, _} -> k end, fn {_, v} -> [v] end)
    {:noreply, state}
  end

  defp connect_to_worker() do
    node = :"#{select_node()}@localhost"
    true = Node.connect(node)
    :pong = Node.ping(node)
    {:ok, node}
  end

  defp select_node() do
    {:ok, names} = :net_adm.names()

    names
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&List.to_string/1)
    |> Enum.filter(&String.starts_with?(&1, "iot_"))
    |> Enum.random()
  end
end
