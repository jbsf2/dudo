defmodule DudoWeb.RootController do
  use DudoWeb, :controller

  def show(conn, params) do
    case get_session(conn, :player_id) do
      nil -> conn |> redirect(to: Routes.login_path(conn, :new))
      _ -> conn |> redirect(to: Routes.welcome_path(conn, :show))
    end
  end

end
