defmodule DomainHolder.Counters.BucketList do
  defstruct buckets: [],
            last_bucket: 0,
            bucket_length: nil,
            bucket_count: nil,
            weight_factor: nil,
            startup_time: nil,
            last_increment: nil

  use GenServer

  require Logger

  alias DomainHolder.Counters.BucketList

  @mseconds_per_day 24 * 60 * 60 * 1000

  def start_link([bucket_count, bucket_length, weight_factor]) do
    GenServer.start_link(__MODULE__, %BucketList{
      bucket_length: bucket_length,
      bucket_count: bucket_count,
      weight_factor: weight_factor
    })
  end

  def increment(bucket_list) do
    GenServer.call(bucket_list, :increment)
  end

  def get_state(bucket_list) do
    GenServer.call(bucket_list, :get_state)
  end

  def count(bucket_list) do
    state = get_state(bucket_list)
    count_buckets(state)
  end

  def weighted_count(bucket_list) do
    state = get_state(bucket_list)
    count_buckets_weighted(state)
  end

  def pings_per_day(bucket_list) do
    state = get_state(bucket_list)

    state
    |> count_buckets_weighted()
    |> extend_buckets_to_day(state)
    |> Kernel.trunc()
  end

  defp count_buckets(%BucketList{buckets: buckets}) do
    Enum.reduce(buckets, 0, fn b, a -> a + b end)
  end

  defp count_buckets_weighted(%BucketList{
         buckets: buckets,
         bucket_count: bucket_count,
         weight_factor: weight_factor
       }) do
    buckets
    |> Enum.with_index()
    |> Enum.reduce(0, fn {o, i}, a ->
      a + o * (weight_factor * ((bucket_count - i) / bucket_count))
    end)
    |> Kernel.trunc()
  end

  defp extend_buckets_to_day(count, %BucketList{
         bucket_length: bucket_length,
         bucket_count: bucket_count
       })
       when count > 0 do
    count * (@mseconds_per_day / (bucket_length * bucket_count))
  end

  defp extend_buckets_to_day(_count, %BucketList{
         bucket_length: bucket_length} = state) do
    ping_gap = Kernel.max(bucket_length, mseconds_since_last_ping(state))

    if ping_gap > @mseconds_per_day do
      0
    else
      1 * (@mseconds_per_day / ping_gap)
    end
  end

  def init(%BucketList{
        bucket_length: bucket_length,
        bucket_count: bucket_count,
        weight_factor: weight_factor
      }) do
    {:ok,
     %BucketList{
       bucket_length: bucket_length,
       bucket_count: bucket_count,
       weight_factor: weight_factor,
       startup_time: DateTime.utc_now(),
       buckets: [0]
     }}
  end

  def handle_call(:get_state, _from, state = %BucketList{last_bucket: last_bucket}) do
    new_state =
      case bucket_name(state) do
        ^last_bucket ->
          state

        new_minute ->
          pad_buckets(state, new_minute)
      end

    {:reply, new_state, new_state}
  end

  def handle_call(:increment, _from, state = %BucketList{last_bucket: last_bucket}) do
    ping_time = DateTime.utc_now()

    new_state =
      case bucket_name(state) do
        ^last_bucket ->
          state
          |> increment_bucket
          |> set_last_bucket(ping_time)

        new_bucket ->
          state
          |> pad_buckets(new_bucket)
          |> increment_bucket
          |> set_last_bucket(ping_time)
      end

    {:reply, new_state, new_state}
  end

  defp bucket_name(%BucketList{
         startup_time: startup_time,
         bucket_length: bucket_length
       }) do
    DateTime.utc_now()
    |> DateTime.diff(startup_time, :millisecond)
    |> Kernel.div(bucket_length)
  end

  defp set_last_bucket(state, new_minute) do
    %{state | last_increment: new_minute}
  end

  defp increment_bucket(state = %BucketList{buckets: [first | rest]}) do
    %{state | buckets: [first + 1 | rest]}
  end

  defp pad_buckets(
         state = %BucketList{
           last_bucket: last_bucket,
           buckets: buckets,
           bucket_count: bucket_count
         },
         new_minute
       ) do
    new_minute = Kernel.min(new_minute, last_bucket + bucket_count)
    ar = Range.new(last_bucket + 1, new_minute)

    buckets =
      Enum.reduce(ar, buckets, fn _b, a -> [0 | a] end)
      |> Enum.take(bucket_count)

    %{state | buckets: buckets, last_bucket: new_minute}
  end

  defp mseconds_since_last_ping(%BucketList{last_increment: nil}) do
    @mseconds_per_day * 2
  end

  defp mseconds_since_last_ping(%BucketList{last_increment: last_increment}) do
    DateTime.diff(DateTime.utc_now(), last_increment, :millisecond)
  end
end
