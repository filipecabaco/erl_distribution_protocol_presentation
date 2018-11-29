defmodule Orchestrator.Application do
  use Application

  def start(_type, _args) do

    Node.start(:server@localhost, :shortnames)
    Node.set_cookie(:secret)

    children = [
      Orchestrator.Iot
    ]

    opts = [strategy: :one_for_one, name: Orchestrator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
