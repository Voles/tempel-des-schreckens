defmodule Schreckens.Game do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(player_count: player_count) do
    {:ok,
     %{
       player_count: player_count,
       remaining_cards: starting_roles(player_count) |> Enum.shuffle(),
       remaining_rooms: starting_rooms(player_count) |> Enum.shuffle(),
       joined_players: %{}
     }}
  end

  def join_state(secret_token) do
    GenServer.call(__MODULE__, {:join_state, secret_token})
  end

  def rooms_for(secret_token) do
    GenServer.call(__MODULE__, {:rooms_for, secret_token})
  end

  def table() do
    GenServer.call(__MODULE__, :table)
  end

  def handle_call({:join_state, secret_token}, _from, state) do
    cond do
      Enum.count(Map.keys(state.joined_players)) == state.player_count ->
        {:reply, :error, state}

      Map.has_key?(state.joined_players, secret_token) ->
        {:reply, :error, state}

      true ->
        [role | remaining] = state.remaining_cards
        {rooms, remaining_rooms} = Enum.split(state.remaining_rooms, 5)

        is_guardian = role == :guardian

        reply = %{
          playerIds: 1..state.player_count |> Enum.to_list(),
          guardian: is_guardian,
          key: Enum.count(Map.keys(state.joined_players)) == 0
        }

        joined_players =
          Map.put(state.joined_players, secret_token, %{
            rooms: rooms
          })

        {:reply, {:ok, reply},
         %{
           state
           | remaining_cards: remaining,
             joined_players: joined_players,
             remaining_rooms: remaining_rooms
         }}
    end
  end

  def handle_call({:rooms_for, secret_token}, _from, state) do
    case Map.get(state.joined_players, secret_token) do
      %{rooms: rooms} ->
        {:reply, {:ok, rooms}, state}

      nil ->
        {:reply, :error, state}
    end
  end

  def handle_call(:table, _from, state) do
    cond do
      Enum.count(Map.keys(state.joined_players)) == state.player_count ->
        table = %{
          key: 1,
          rooms: %{
            1 => ["closed", "closed", "closed", "closed", "closed"],
            2 => ["closed", "closed", "closed", "closed", "closed"],
            3 => ["closed", "closed", "closed", "closed", "closed"]
          },
          found: %{
            traps: 0,
            treasure: 0,
            empty: 0
          }
        }

        {:reply, {:ok, table}, state}

      true ->
        {:reply, :error, state}
    end
  end

  defp starting_roles(3), do: [:guardian, :guardian, :adventurer, :adventurer]

  defp starting_rooms(3),
    do:
      [for(_ <- 1..8, do: :empty), for(_ <- 1..5, do: :treasure), for(_ <- 1..2, do: :trap)]
      |> Enum.flat_map(& &1)
end

defmodule SchreckensWeb.GameController do
  use SchreckensWeb, :controller

  alias Schreckens.Game

  def start(conn, %{"playerCount" => player_count})
      when player_count >= 3 and player_count <= 10 do
    {:ok, _pid} = Game.start_link(player_count: player_count)

    json(conn, "ok")
  end

  def start(conn, _param), do: error(conn)

  def join(conn, %{"secretToken" => secret_token}) when is_binary(secret_token) do
    case Process.whereis(Game) do
      pid when is_pid(pid) ->
        case Game.join_state(secret_token) do
          {:ok, join_state} -> json(conn, join_state)
          :error -> error(conn)
        end

      _ ->
        error(conn)
    end
  end

  def join(conn, _param), do: error(conn)

  def my_rooms(conn, %{"secret_token" => secret_token}) when is_binary(secret_token) do
    case Process.whereis(Game) do
      pid when is_pid(pid) ->
        case Game.rooms_for(secret_token) do
          {:ok, rooms} -> json(conn, %{rooms: rooms})
          :error -> error(conn)
        end

      _ ->
        error(conn)
    end
  end

  def my_rooms(conn, _params), do: error(conn)

  def table(conn, _params) do
    case Process.whereis(Game) do
      pid when is_pid(pid) ->
        case Game.table() do
          {:ok, table} -> json(conn, table)
          :error -> error(conn, 404)
        end

      _ ->
        error(conn, 404)
    end
  end

  defp error(conn, status \\ 400) do
    conn
    |> put_status(status)
    |> json("error")
  end
end
