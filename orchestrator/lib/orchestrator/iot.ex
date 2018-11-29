defmodule Orchestrator.Iot do
  use GenServer

  def init(_), do: {:ok, []}
  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def handle_call({:msg, message}, _sender, _state) do
    {:ok, node} = connect_to_worker()
    send({:mailbox, node}, to_charlist(message))
    {:reply, :ok, []}
  end

  defp connect_to_worker() do
    node = :iot@localhost
    true = Node.connect(node)
    :pong = Node.ping(node)
    {:ok, node}
  end
end
