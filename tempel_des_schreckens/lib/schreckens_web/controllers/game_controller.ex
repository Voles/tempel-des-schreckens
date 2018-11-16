defmodule SchreckensWeb.GameController do
  use SchreckensWeb, :controller

  def start(conn, _params) do
    json(conn, "")
  end
end
