defmodule DomainHolder.Counters.Counter do
  defstruct short_term_timer: nil,
            long_term_timer: nil

  use GenServer

  require Logger

  alias DomainHolder.Counters.BucketList
  alias DomainHolder.Counters.Counter

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{}, name: Counter)
  end

  def increment() do
    GenServer.call(Counter, :increment)
  end

  def pings_per_day() do
    GenServer.call(Counter, :pings_per_day)
  end

  def init(%{}) do
    Logger.debug("init running counter")

    {:ok, short_term_timer} = BucketList.start_link([15, 2000, 3])
    {:ok, long_term_timer} = BucketList.start_link([60, 15000, 2])

    {:ok,
     %Counter{
       short_term_timer: short_term_timer,
       long_term_timer: long_term_timer
     }}
  end

  def handle_call(
        :increment,
        _from,
        state = %{short_term_timer: short_term_timer, long_term_timer: long_term_timer}
      ) do
    BucketList.increment(short_term_timer)
    BucketList.increment(long_term_timer)

    {:reply, state, state}
  end

  def handle_call(
        :pings_per_day,
        _from,
        state = %{short_term_timer: short_term_timer, long_term_timer: long_term_timer}
      ) do
    short_ppd = BucketList.pings_per_day(short_term_timer)
    long_ppd = BucketList.pings_per_day(long_term_timer)

    new_state =
      state
      |> Map.merge(%{short_term_average: short_ppd})
      |> Map.merge(%{long_term_average: long_ppd})

    {:reply, new_state, state}
  end
end
