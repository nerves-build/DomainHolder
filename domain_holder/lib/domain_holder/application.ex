defmodule DomainHolder.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias DomainHolder.Domains.State
  alias DomainHolder.Counters.Counter
  alias DomainHolder.Counters.Heartbeat

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      Counter,
      Heartbeat,
      DomainHolderWeb.Endpoint,
      # start up the domain state
      State
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DomainHolder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DomainHolderWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
