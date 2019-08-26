defmodule NetworkInterfaceStub do
  @moduledoc false

  def settings(_name) do
    {:ok, interfaces} = :inet.getifaddrs()

    {_name, int_data} =
      interfaces
      |> Enum.filter(&has_local_interface?(&1))
      |> Enum.at(0)

    {ip1, ip2, ip3, ip4} =
      int_data
      |> Keyword.get_values(:addr)
      |> Enum.filter(&local_interface?(&1))
      |> Enum.at(0)

    mac_string =
      int_data
      |> Keyword.get(:hwaddr, [])
      |> Enum.map(&Integer.to_string(&1, 16))
      |> Enum.join(":")

    {:ok,
     %{
       ipv4_address: "#{ip1}.#{ip2}.#{ip3}.#{ip4}",
       mac_address: mac_string
     }}
  end

  defp has_local_interface?({_name, if_data}) do
    case Keyword.get_values(if_data, :addr) do
      [] ->
        false

      addrs ->
        Enum.any?(addrs, &local_interface?(&1))
    end
  end

  defp local_interface?(addr) do
    case addr do
      {10, 0, 1, _any} ->
        true

      _any_other ->
        false
    end
  end
end
