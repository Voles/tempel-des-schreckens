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

  test "POST /join without a started game", %{conn: conn} do
    conn = post(conn, "/join", %{secretToken: "some_secret"})
    assert "error" = json_response(conn, 400)
  end

  test "POST /join with a started game", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    conn = post(conn, "/join", %{secretToken: "some_secret"})

    assert %{
             "guardian" => guardian,
             "playerIds" => [1, 2, 3]
           } = json_response(conn, 200)

    assert is_boolean(guardian)
  end
end
