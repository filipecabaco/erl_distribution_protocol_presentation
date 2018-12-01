defmodule Orchestrator.Iot do
  use GenServer

  def init(_), do: {:ok, %{}}

  def start_link(_) do
    "orchestrator@localhost"
    |> String.to_atom()
    |> Node.start(:shortnames)

    Node.set_cookie(:secret)

    # Add to give atom as name, had issues when receiving from Python
    GenServer.start_link(__MODULE__, %{}, name: :orchestrator)
  end

  def handle_call({:msg, message}, _sender, state) do
    {:ok, node} = connect_to_worker()
    send({:mailbox, node}, to_charlist(message))
    {:reply, :ok, state}
  end

  def handle_call(:metrics, _sender, state) do
    {:reply, state, state}
  end

  def handle_info({client, msg}, state) do
    state = Map.update(state, client, {1, [msg]}, &update_metrics(&1, msg))
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

  defp update_metrics({counter, messages}, new_message) do
    {counter + 1, messages ++ [new_message]}
  end
end
