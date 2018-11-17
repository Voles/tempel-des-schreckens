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
    assert "error" = json_response(conn, 404)
  end

  test "POST /join with a started game", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    conn = post(conn, "/join", %{secretToken: "some_secret"})

    assert %{
             "guardian" => guardian,
             "playerIds" => [1, 2, 3],
             "key" => true,
             "id" => 1
           } = json_response(conn, 200)

    assert is_boolean(guardian)
  end

  test "POST /join 3 players should have a correct amount of guardians", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    response1 = post(conn, "/join", %{secretToken: "1"})
    response2 = post(conn, "/join", %{secretToken: "2"})
    response3 = post(conn, "/join", %{secretToken: "3"})

    %{"guardian" => guardian1, "id" => 1} = json_response(response1, 200)
    %{"guardian" => guardian2, "id" => 2} = json_response(response2, 200)
    %{"guardian" => guardian3, "id" => 3} = json_response(response3, 200)

    nb_of_guardians =
      [guardian1, guardian2, guardian3]
      |> Enum.filter(fn
        true -> true
        false -> false
      end)
      |> Enum.count()

    assert nb_of_guardians == 1 || nb_of_guardians == 2
  end

  test "POST /join 3 players, exactly 1 player should have the key", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    response1 = post(conn, "/join", %{secretToken: "1"})
    response2 = post(conn, "/join", %{secretToken: "2"})
    response3 = post(conn, "/join", %{secretToken: "3"})

    %{"key" => key1} = json_response(response1, 200)
    %{"key" => key2} = json_response(response2, 200)
    %{"key" => key3} = json_response(response3, 200)

    nb_of_keys =
      [key1, key2, key3]
      |> Enum.filter(fn
        true -> true
        false -> false
      end)
      |> Enum.count()

    assert nb_of_keys == 1
  end

  test "POST /join rejoin results in an error", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})

    response1 = post(conn, "/join", %{secretToken: "1"})
    response2 = post(conn, "/join", %{secretToken: "1"})

    %{} = json_response(response1, 200)
    "error" = json_response(response2, 400)
  end

  test "POST /join 4th join results in an error", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})

    post(conn, "/join", %{secretToken: "1"})
    post(conn, "/join", %{secretToken: "2"})
    post(conn, "/join", %{secretToken: "3"})
    response = post(conn, "/join", %{secretToken: "4"})

    "error" = json_response(response, 400)
  end

  test "GET /my-rooms returns 5 rooms", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})

    post(conn, "/join", %{secretToken: "my-secret"})
    response = get(conn, "/my-rooms/my-secret")

    assert %{"rooms" => rooms} = json_response(response, 200)
    assert Enum.count(rooms) == 5
  end

  test "GET /my-rooms but not joined yet", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})

    response = get(conn, "/my-rooms/my-secret")

    assert "error" = json_response(response, 400)
  end

  test "GET /my-rooms is idempotent", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "my-secret"})

    response1 = get(conn, "/my-rooms/my-secret")
    response2 = get(conn, "/my-rooms/my-secret")

    assert %{"rooms" => rooms} = json_response(response1, 200)
    assert %{"rooms" => ^rooms} = json_response(response2, 200)
  end

  test "GET /table before all players have joined", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    response = get(conn, "/table")

    json_response(response, 404)
  end

  test "GET /table before any action", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "1"})
    post(conn, "/join", %{secretToken: "2"})
    post(conn, "/join", %{secretToken: "3"})

    response = get(conn, "/table")

    assert %{
             "key" => 1,
             "rooms" => %{
               "1" => ["closed", "closed", "closed", "closed", "closed"],
               "2" => ["closed", "closed", "closed", "closed", "closed"],
               "3" => ["closed", "closed", "closed", "closed", "closed"]
             },
             "found" => %{
               "trap" => 0,
               "treasure" => 0,
               "empty" => 0
             }
           } = json_response(response, 200)
  end

  test "POST /open before everyone joined", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "secret"})

    response = post(conn, "/open", %{secretToken: "secret", targetPlayerId: "2"})

    assert "error" = json_response(response, 400)
  end

  test "POST /open you can't open a door if you don't have the key", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "secret1"})
    post(conn, "/join", %{secretToken: "secret2"})
    post(conn, "/join", %{secretToken: "secret3"})

    response = post(conn, "/open", %{secretToken: "secret2", targetPlayerId: "1"})

    assert "error" = json_response(response, 400)
  end

  test "POST /open you can open a door if you do have the key", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "secret1"})
    post(conn, "/join", %{secretToken: "secret2"})
    post(conn, "/join", %{secretToken: "secret3"})

    response = post(conn, "/open", %{secretToken: "secret1", targetPlayerId: "2"})

    assert json_response(response, 200)
  end

  test "POST /open you can't open your own doors", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "secret1"})
    post(conn, "/join", %{secretToken: "secret2"})
    post(conn, "/join", %{secretToken: "secret3"})

    response = post(conn, "/open", %{secretToken: "secret1", targetPlayerId: "1"})

    assert "error" = json_response(response, 400)
  end

  test "POST /open should reveal a room", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "secret1"})
    post(conn, "/join", %{secretToken: "secret2"})
    post(conn, "/join", %{secretToken: "secret3"})

    response = post(conn, "/open", %{secretToken: "secret1", targetPlayerId: "2"})

    assert json_response(response, 200)

    response = get(conn, "/table")

    assert %{
             "key" => 2,
             "rooms" => %{
               "1" => ["closed", "closed", "closed", "closed", "closed"],
               "2" => rooms,
               "3" => ["closed", "closed", "closed", "closed", "closed"]
             },
             "found" => %{
               "trap" => 0,
               "treasure" => 0,
               "empty" => 0
             }
           } = json_response(response, 200)

    assert_number_of_opened_rooms(rooms, 1)
  end

  test "POST /open should reveal another room", %{conn: conn} do
    conn = post(conn, "/start", %{playerCount: 3})
    post(conn, "/join", %{secretToken: "secret1"})
    post(conn, "/join", %{secretToken: "secret2"})
    post(conn, "/join", %{secretToken: "secret3"})

    post(conn, "/open", %{secretToken: "secret1", targetPlayerId: "2"})
    post(conn, "/open", %{secretToken: "secret2", targetPlayerId: "3"})

    response = get(conn, "/table")

    assert %{
             "key" => 3,
             "rooms" => %{
               "1" => ["closed", "closed", "closed", "closed", "closed"],
               "2" => rooms2,
               "3" => rooms3
             },
             "found" => %{
               "trap" => 0,
               "treasure" => 0,
               "empty" => 0
             }
           } = json_response(response, 200)

    assert_number_of_opened_rooms(rooms2, 1)
    assert_number_of_opened_rooms(rooms3, 1)
  end

  # test "POST /open for last door of round", %{conn: conn} do
  #   conn = post(conn, "/start", %{playerCount: 3})
  #   post(conn, "/join", %{secretToken: "secret1"})
  #   post(conn, "/join", %{secretToken: "secret2"})
  #   post(conn, "/join", %{secretToken: "secret3"})
  #
  #   post(conn, "/open", %{secretToken: "secret1", targetPlayerId: "2"})
  #   post(conn, "/open", %{secretToken: "secret2", targetPlayerId: "3"})
  #   post(conn, "/open", %{secretToken: "secret3", targetPlayerId: "2"})
  #
  #   response = get(conn, "/table")
  #
  #   assert %{
  #            "key" => 2,
  #            "rooms" => %{
  #              "1" => ["closed", "closed", "closed", "closed"],
  #              "2" => ["closed", "closed", "closed", "closed"],
  #              "3" => ["closed", "closed", "closed", "closed"]
  #            },
  #            "found" => %{
  #              "trap" => trap,
  #              "treasure" => treasure,
  #              "empty" => empty
  #            }
  #          } = json_response(response, 200)
  #
  #   assert 3 = trap + treasure + empty
  # end

  defp assert_number_of_opened_rooms(rooms, number) do
    opened_rooms =
      rooms
      |> Enum.filter(fn
        "closed" -> false
        _ -> true
      end)

    assert number == Enum.count(opened_rooms)

    Enum.all?(opened_rooms, fn opened_room ->
      assert opened_room in ["empty", "trap", "treasure"]
    end)
  end
end
