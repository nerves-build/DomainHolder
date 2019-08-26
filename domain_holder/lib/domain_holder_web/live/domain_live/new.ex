defmodule DomainHolderWeb.DomainLive.New do
  use Phoenix.LiveView

  alias DomainHolderWeb.DomainLive
  alias DomainHolderWeb.Router.Helpers, as: Routes
  alias DomainHolder.Domains
  alias DomainHolder.Domains.Domain

  def mount(_session, socket) do
    {:ok,
     assign(socket, %{
       changeset: Domains.change_domain(%Domain{}, %{})
     })}
  end

  def render(assigns), do: DomainHolderWeb.DomainView.render("new.html", assigns)

  def handle_event("validate", %{"domain" => params}, socket) do
    changeset =
      %Domain{}
      |> DomainHolder.Domains.change_domain(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"domain" => user_params}, socket) do
    case Domains.create_domain(user_params) do
      {:ok, _domain} ->
        {:stop,
         socket
         |> redirect(to: Routes.live_path(socket, DomainLive.Index))}

      {:error, %Domain{} = domain} ->
        {:noreply, assign(socket, changeset: domain)}
    end
  end
end
