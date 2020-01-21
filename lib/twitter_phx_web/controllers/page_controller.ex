defmodule TwitterPhxWeb.PageController do
  use TwitterPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
