defmodule Orchestrator.Iot do
  use GenServer

  def init(_), do: {:ok, []}
  def start_link(_) do
    "orchestrator_#{UUID.uuid4()}@localhost"
    |> String.to_atom()
    |> Node.start(:shortnames)
    Node.set_cookie(:secret)

    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_call({:msg, message}, _sender, _state) do
    {:ok, node} = connect_to_worker()
    send({:mailbox, node}, to_charlist(message))
    {:reply, :ok, []}
  end

  defp connect_to_worker() do
    node = :"#{select_worker()}@localhost"
    true = Node.connect(node)
    :pong = Node.ping(node)
    {:ok, node}
  end

  defp select_worker() do
    {:ok, names} = :net_adm.names()
    names
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.map(&List.to_string/1)
    |> Enum.filter(&(String.starts_with?(&1, "iot_")))
    |> Enum.random
  end
end
