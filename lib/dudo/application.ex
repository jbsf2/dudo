defmodule Dudo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DudoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Dudo.PubSub},
      # Start the Endpoint (http/https)
      DudoWeb.Endpoint,
      # Start a worker by calling: Dudo.Worker.start_link(arg)
      # {Dudo.Worker, arg}

      {Registry, keys: :unique, name: :game_id_registry},
      {DynamicSupervisor, strategy: :one_for_one, name: :game_supervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dudo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DudoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
