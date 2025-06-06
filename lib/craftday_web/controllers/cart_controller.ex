defmodule CraftdayWeb.CartController do
  use CraftdayWeb, :controller

  def clear(conn, _params) do
    conn
    |> delete_session(:cart_id)
    |> redirect(to: ~p"/cart")
  end
end
