defmodule DomainHolderWeb.DomainLive.Edit do
  use Phoenix.LiveView

  alias DomainHolderWeb.DomainLive
  alias DomainHolderWeb.Router.Helpers, as: Routes
  alias DomainHolder.Domains

  def mount(%{path_params: %{"id" => id}}, socket) do
    domain = Domains.get_domain!(id)
    {:ok, assign(socket, %{domain: domain, changeset: Domains.change_domain(domain, %{})})}
  end

  def render(assigns), do: DomainHolderWeb.DomainView.render("edit.html", assigns)

  def handle_event("validate", %{"domain" => params}, socket) do
    changeset =
      socket.assigns.domain
      |> DomainHolder.Domains.change_domain(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"domain" => user_params}, socket) do
    case Domains.update_domain(socket.assigns.domain, user_params) do
      {:ok, _domain} ->
        {:stop,
         socket
         |> redirect(to: Routes.live_path(socket, DomainLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
