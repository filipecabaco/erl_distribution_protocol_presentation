defmodule Orchestrator.Application do
  use Application

  def start(_type, _args) do
    children = [
      Orchestrator.Iot
    ]

    opts = [strategy: :one_for_one, name: Orchestrator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
