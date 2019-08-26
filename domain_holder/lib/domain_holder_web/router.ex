defmodule DomainHolderWeb.Router do
  use DomainHolderWeb, :router
  import Phoenix.LiveView.Router

  alias DomainHolderWeb.Plugs.DomainChecker

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {DomainHolderWeb.LayoutView, :app}
    plug DomainChecker
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DomainHolderWeb do
    pipe_through :browser

    live "/", DomainLive.Index
    live "/domains/new", DomainLive.New
    live "/domains/:id/edit", DomainLive.Edit

    resources "/plain/domains", DomainController
  end

  # Other scopes may use custom stacks.
  # scope "/api", DomainHolderWeb do
  #   pipe_through :api
  # end
end
