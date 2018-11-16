defmodule SchreckensWeb.GameControllerTest do
  use SchreckensWeb.ConnCase

  test "POST /start", %{conn: conn} do
    conn = post(conn, "/start")
    assert json_response(conn, 200)
  end
end
