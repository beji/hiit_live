defmodule HiitLiveWeb.Router do
  use HiitLiveWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HiitLiveWeb do
    pipe_through :browser
    live "/", HiitLive
    # get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", HiitLiveWeb do
  #   pipe_through :api
  # end
end
