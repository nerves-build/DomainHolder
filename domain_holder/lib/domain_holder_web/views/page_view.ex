defmodule DomainHolderWeb.PageView do
  use DomainHolderWeb, :view

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
end
