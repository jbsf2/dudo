defmodule DudoWeb.LoginController do
  use DudoWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, _params) do
    render(conn, "new.html")
  end
end