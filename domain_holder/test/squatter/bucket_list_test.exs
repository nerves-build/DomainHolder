defmodule DomainHolderWeb.BucketListTest do
  use ExUnit.Case

  alias DomainHolder.Counters.BucketList

  setup do
    {:ok, test_timer} = BucketList.start_link([10, 20, 3])
    %{test_timer: test_timer}
  end

  test "starts at 0", %{test_timer: test_timer} do
    assert BucketList.count(test_timer) == 0
  end

  test "increments by 1", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    assert BucketList.count(test_timer) == 1
  end

  test "pads buckets over time", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    Process.sleep(40)
    BucketList.increment(test_timer)

    %{buckets: buckets} = BucketList.get_state(test_timer)

    assert buckets == [1, 0, 1]
  end

  test "pads buckets over time differnt", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    Process.sleep(40)

    %{buckets: buckets} = BucketList.get_state(test_timer)

    assert buckets == [0, 0, 1]
  end

  test "pads buckets over time again", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    Process.sleep(2)
    BucketList.increment(test_timer)
    Process.sleep(2)
    BucketList.increment(test_timer)
    Process.sleep(40)
    BucketList.increment(test_timer)

    %{buckets: buckets} = BucketList.get_state(test_timer)

    assert buckets == [1, 0, 3]
  end

  test "can weight the counts", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    assert BucketList.weighted_count(test_timer) == 3
  end

  test "the weight decreases over time", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    Process.sleep(40)

    assert BucketList.weighted_count(test_timer) == 2
  end

  test "can prorate the count over a day", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    assert BucketList.pings_per_day(test_timer) == 1_296_000
  end

  test "the prorate decreases over time", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    Process.sleep(80)

    assert BucketList.pings_per_day(test_timer) == 432_000
  end

  test "the prorate still works past the bicket length", %{test_timer: test_timer} do
    BucketList.increment(test_timer)
    Process.sleep(410)

    assert BucketList.pings_per_day(test_timer) == 210_218
  end
end
