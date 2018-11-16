defmodule SchreckensWeb.GameController do
  use SchreckensWeb, :controller

  def start(conn, %{"playerCount" => playerCount}) when playerCount >= 3 and playerCount <= 10 do
    json(conn, "ok")
  end

  def start(conn, _param), do: error(conn)

  def join(conn, %{"secretToken" => secretToken}) when is_binary(secretToken) do
    error(conn)
  end

  def join(conn, _param), do: error(conn)

  defp error(conn) do
    conn
    |> put_status(400)
    |> json("error")
  end
end
