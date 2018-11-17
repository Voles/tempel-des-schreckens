defmodule SchreckensWeb.GameController do
  use SchreckensWeb, :controller

  alias Schreckens.Game

  action_fallback SchreckensWeb.FallbackController

  def start(conn, %{"playerCount" => player_count})
      when player_count >= 3 and player_count <= 10 do
    {:ok, _pid} = Game.start_link(player_count: player_count)

    json(conn, "ok")
  end

  def start(conn, _param), do: error(conn)

  def join(conn, %{"secretToken" => secret_token}) when is_binary(secret_token) do
    with {:ok, _game} <- find_game() do
      case Game.join_state(secret_token) do
        {:ok, join_state} -> json(conn, join_state)
        :error -> error(conn)
      end
    end
  end

  def join(conn, _param), do: error(conn)

  def my_rooms(conn, %{"secret_token" => secret_token}) when is_binary(secret_token) do
    with {:ok, _game} <- find_game() do
      case Game.rooms_for(secret_token) do
        {:ok, rooms} -> json(conn, %{rooms: rooms})
        :error -> error(conn)
      end
    end
  end

  def my_rooms(conn, _params), do: error(conn)

  def table(conn, _params) do
    with {:ok, _game} <- find_game() do
      case Game.table() do
        {:ok, table} -> json(conn, table)
        :error -> error(conn, 404)
      end
    end
  end

  def open(conn, %{"secretToken" => secret_token, "targetPlayerId" => target_player_id}) do
    with {:ok, _game} <- find_game(),
         {target_player_id, ""} <- Integer.parse(target_player_id) do
      case Game.open(secret_token, target_player_id) do
        :ok -> json(conn, "ok")
        :error -> error(conn)
      end
    end
  end

  def open(conn, _params), do: error(conn)

  defp error(conn, status \\ 400) do
    conn
    |> put_status(status)
    |> json("error")
  end

  defp find_game() do
    case Process.whereis(Game) do
      pid when is_pid(pid) ->
        {:ok, pid}

      _ ->
        {:error, :not_found}
    end
  end
end
