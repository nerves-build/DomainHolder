defmodule DomainHolder.Counters.Heartbeat do
  defstruct target: nil,
            looping: false

  use GenServer

  alias DomainHolder.Counters.Heartbeat
  alias DomainHolder.Device

  @target Mix.target()

  def start_link([]) do
    GenServer.start_link(__MODULE__, %Heartbeat{target: @target}, name: Heartbeat)
  end

  def init(state) do
    {:ok, schedule_heartbeat(state)}
  end

  def handle_info(:tick, state = %{looping: false}) do
    {:noreply, state}
  end

  def handle_info(:tick, state) do
    state =
      state
      |> handle_beat
      |> schedule_heartbeat

    {:noreply, state}
  end

  defp handle_beat(state) do
    Device.handle_beat()
    state
  end

  defp schedule_heartbeat(state = %{}) do
    Process.send_after(self(), :tick, 1000)

    %{state | looping: true}
  end
end
