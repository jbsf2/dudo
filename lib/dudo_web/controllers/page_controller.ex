defmodule DudoWeb.PageController do
  use DudoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
