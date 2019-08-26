defmodule DomainHolderWeb.DomainLive.Index do
  use Phoenix.LiveView

  alias DomainHolder.Domains
  alias DomainHolderWeb.DomainView
  alias DomainHolder.Counters

  def mount(_session, socket) do
    if connected?(socket) do
      Domains.subscribe()
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, fetch(socket)}
  end

  def render(assigns), do: DomainView.render("index.html", assigns)

  defp fetch(socket) do
    %{
      short_term_average: short_term,
      long_term_average: long_term
    } = Counters.pings_per_day()

    domains = Domains.list_domains()
    total_count = Enum.reduce(domains, 0, fn {_, i}, a -> a + i.count end)

    assign(socket,
      domains: domains,
      short_term: Kernel.trunc(short_term),
      long_term: Kernel.trunc(long_term),
      total_count: total_count
    )
  end

  def handle_info(:tick, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Domains, [:domain | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({Counters, [:counter | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_event("delete_domain", id, socket) do
    id
    |> Domains.get_domain()
    |> Domains.delete_domain()

    {:noreply, socket}
  end
end
