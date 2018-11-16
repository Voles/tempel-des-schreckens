defmodule SchreckensWeb.GameControllerTest do
  use SchreckensWeb.ConnCase

  test "POST /start with correct arguments", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    assert "ok" = json_response(conn, 200)
  end

  test "POST /start with incorrect arguments", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 11})
    assert "error" = json_response(conn, 400)
  end
end
