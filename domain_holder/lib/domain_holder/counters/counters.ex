defmodule DomainHolder.Counters do
  @moduledoc """
  The Counters context.
  """
  alias DomainHolder.Counters.Counter

  @topic inspect(DomainHolder.Domains)

  def increment() do
    Counter.increment()
    |> notify_subscribers([:counter, :updated])
  end

  def pings_per_day() do
    Counter.pings_per_day()
  end

  defp notify_subscribers(result, event) do
    Phoenix.PubSub.broadcast(DomainHolder.PubSub, @topic, {__MODULE__, event, result})
    result
  end
end
