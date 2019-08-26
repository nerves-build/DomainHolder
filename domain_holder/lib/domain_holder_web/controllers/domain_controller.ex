defmodule DomainHolderWeb.DomainController do
  use DomainHolderWeb, :controller

  alias DomainHolder.Domains
  alias DomainHolder.Domains.Domain

  def index(conn, _params) do
    conn
    |> put_view(DomainHolderWeb.DomainIndexView)
    |> render("index.html")
  end

  def new(conn, _params) do
    render(conn, "new.html", changeset: Domains.change_domain(%Domain{}, %{}), token: get_csrf_token())
  end

  def create(conn, %{"domain" => domain_params}) do
    case Domains.create_domain(domain_params) do
      {:ok, _changeset} ->
        redirect(conn, to: Routes.domain_path(conn, :index))

      {:error, _changeset} ->
        render(conn, "new.html", domain: %Domain{})
    end
  end

  def show(conn, %{"id" => id}) do
    domain = Domains.get_domain!(id)
    render(conn, "show.html", domain: domain)
  end

  def edit(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)
    domain = Domains.get_domain!(id)
    render(conn, "edit.html", changeset: Domains.change_domain(domain, %{}))
  end

  def update(conn, %{"id" => id, "domain" => domain_params}) do
    {id, _} = Integer.parse(id)
    domain = Domains.get_domain!(id)

    case Domains.update_domain(domain, domain_params) do
      {:ok, _domain} ->
        render(conn, "_listing.html", conn: conn, domains: Domains.list_domains())

      {:error, changeset} ->
        render(conn, "edit.html", domain: domain, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)
    domain = Domains.get_domain!(id)
    Domains.delete_domain(domain)

    render(conn, "_listing.html", conn: conn, domains: Domains.list_domains())
  end
end
