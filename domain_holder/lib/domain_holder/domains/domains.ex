defmodule DomainHolder.Domains do
  @moduledoc """
  The Domains context.
  """
  import Ecto.Query, warn: false

  alias DomainHolder.Domains.State
  alias Plug.Conn
  alias DomainHolder.Domains.Domain
  alias DomainHolder.Counters

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(DomainHolder.PubSub, @topic)
  end

  def list_domains() do
    State.get_domains()
  end

  def get_domain!(conn) do
    case get_domain(conn) do
      nil -> nil
      domain -> domain
    end
  end

  def create_domain(attrs \\ %{}) do
    State.add_domain(attrs)
    |> notify_subscribers([:domain, :created])
  end

  def change_domain(domain, params) do
    Domain.changeset(domain, params)
  end

  def update_domain(%Domain{} = domain, attrs) do
    State.update_domain(domain, attrs)
    |> notify_subscribers([:domain, :updated])
  end

  def delete_domain(%Domain{} = domain) do
    State.delete_domain(domain)
    |> notify_subscribers([:domain, :deleted])
  end

  def get_domain_by_host(conn = %{host: host}) do
    referrers = Conn.get_req_header(conn, "referer")

    if Enum.empty?(referrers) do
      get_domain_by_host(Map.values(list_domains()), host)
    else
      get_domain_by_host(Map.values(list_domains()), Enum.at(referrers, 0))
    end
  end

  def get_domain(id) do
    Map.get(list_domains(), id)
  end

  def increment_counter() do
    Counters.increment()
  end

  def increment_counter(domain) do
    Counters.increment()

    State.increment_counter(domain)
    |> notify_subscribers([:domain, :updated])
  end

  def get_domain_by_host([], _host), do: nil

  def get_domain_by_host([first | rest], host) do
    case check_domain(first, host) do
      nil -> get_domain_by_host(rest, host)
      domain -> domain
    end
  end

  def check_domain(domain, host) do
    if String.contains?(host, domain.host) do
      domain
    else
      nil
    end
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(DomainHolder.PubSub, @topic, {__MODULE__, event, result})

    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
