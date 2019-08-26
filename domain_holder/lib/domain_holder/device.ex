defmodule DomainHolder.Device do
  alias BlinkOMeter.Color
  alias DomainHolder.Counters

  def pop_intensity() do
    %{
      short_term_average: short_term,
      long_term_average: long_term
    } = Counters.pings_per_day()

    long_term
    |> hits_to_uv_level
    |> BlinkOMeter.set_meter_level()

    short_term
    |> hits_to_color
    |> BlinkOMeter.increment_intensity_set_color(25)
  end

  def network_settings(_name) do
    network_adapter().settings("wlan0")
  end

  def handle_beat() do
    %{
      short_term_average: short_term,
      long_term_average: long_term
    } = Counters.pings_per_day()

    short_term
    |> hits_to_color
    |> BlinkOMeter.set_color()

    long_term
    |> hits_to_uv_level
    |> BlinkOMeter.set_meter_level()
  end

  defp hits_to_color(hits) when hits <= 50000 do
    %Color{red: 10, blue: 220, green: 20, intensity: nil}
  end

  defp hits_to_color(hits) when hits <= 150_000 do
    %Color{red: 10, blue: 20, green: 220, intensity: nil}
  end

  defp hits_to_color(_hits) do
    %Color{red: 220, blue: 20, green: 20, intensity: nil}
  end

  defp hits_to_uv_level(hits) when hits <= 0 do
    0
  end

  defp hits_to_uv_level(hits) do
    hits
    |> :math.log()
    |> multiply_by(10)
    |> Kernel.min(100)
    |> Kernel.max(0)
  end

  def multiply_by(number, factor \\ 2) do
    number * factor
  end

  def network_adapter do
    Application.get_env(:domain_holder, :network_adapter)
  end
end
