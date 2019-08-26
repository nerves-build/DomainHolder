defmodule DomainHolderWeb.DomainView do
  use DomainHolderWeb, :view

  alias BlinkOMeter.Color
  alias DomainHolder.Domains.Domain

  def display_name(%Domain{name: nil, host: host}) do
    host
  end

  def display_name(%Domain{name: "", host: host}) do
    host
  end

  def display_name(%Domain{name: name}) do
    name
  end

  def display_name(%Domain{id: id}) do
    "id #{id}"
  end

  def color_to_css(%Color{red: red, green: green, blue: blue, intensity: nil}) do
    "rgba(#{red}, #{green}, #{blue}, 0)"
  end

  def color_to_css(%Color{red: red, green: green, blue: blue, intensity: intensity}) do
    "rgba(#{red}, #{green}, #{blue}, #{intensity / 255.0})"
  end

  alias DomainHolderWeb.DomainLive
end
