defmodule DomainHolderWeb.Plugs.DomainChecker do
  require Logger

  alias Plug.Conn
  alias Phoenix.View
  alias DomainHolder.Domains
  alias DomainHolder.Domains.Domain
  alias DomainHolder.Device

  def init(_opts), do: %{}

  # This function will be called to handle a web request, and must be present.
  def call(conn, _opts) do
    conn =
      # Check our persistance layer to see if the requested domain is a known one
      case Domains.get_domain_by_host(conn) do
        nil ->
          # It isn't a known host, check to see if it's a request for the web app.
          if is_local_access?(conn.host) do
            Conn.assign(conn, :domains, Domains.list_domains())
          else
            Domains.increment_counter()
            Device.pop_intensity()

            %Domain{host: conn.host, tagline: "you never know what you're getting"}
            |> render_domain(conn)
          end

        # In this case the domain was found, put up it's landing page
        domain ->
          case conn.path_info do
            [] ->
              Domains.increment_counter(domain)
              Device.pop_intensity()
              render_domain(domain, conn)

            _any_other ->
              conn
          end
      end
    conn
  end

  # In any case where we render a landing page we terminate the request at that point
  defp render_domain(domain, conn) do
    body = View.render_to_string(DomainHolderWeb.PageView, "show.html", conn: conn, domain: domain)

    conn
    |> Conn.update_resp_header(
      "content-type",
      "text/html; charset=utf-8",
      &(&1 <> "; charset=utf-8")
    )
    |> Conn.delete_resp_header("x-frame-options")
    |> Conn.send_resp(200, body)
    |> Conn.halt()
  end

  defp is_local_access?(domain) do
    String.ends_with?(domain, ".local") || String.contains?(domain, "localhost")
  end
end
