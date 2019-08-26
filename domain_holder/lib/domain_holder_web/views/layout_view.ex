defmodule DomainHolderWeb.LayoutView do
  use DomainHolderWeb, :view

  alias DomainHolder.Device

  @target Mix.target()

  def draw_network_info() do
    {:ok,
     %{
       ipv4_address: ip_address,
       mac_address: mac_address
     }} = Device.network_settings(@target)

    raw(
      "<div> IP Address: #{ip_address} </div>" <>
        "<div> MAC Address: #{mac_address} </div>"
    )
  end
end
