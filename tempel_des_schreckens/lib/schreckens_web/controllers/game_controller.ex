defmodule SchreckensWeb.GameController do
  use SchreckensWeb, :controller

  def start(conn, %{"playerCount" => playerCount}) when playerCount >= 3 and playerCount <= 10 do
    json(conn, "ok")
  end

  def start(conn, _params) do
    conn
    |> put_status(400)
    |> json("error")
  end
end
