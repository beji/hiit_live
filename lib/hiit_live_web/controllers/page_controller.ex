defmodule HiitLiveWeb.PageController do
  use HiitLiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
