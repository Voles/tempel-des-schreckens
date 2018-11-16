defmodule Schreckens.Game do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(playerCount: playerCount) do
    {:ok,
     %{
       playerCount: playerCount,
       remaining_cards: starting_roles(playerCount) |> Enum.shuffle(),
       joined_players: %{}
     }}
  end

  def join_state(secret_token) do
    GenServer.call(__MODULE__, {:join_state, secret_token})
  end

  def handle_call({:join_state, secret_token}, _from, state) do
    cond do
      Enum.count(Map.keys(state.joined_players)) == state.playerCount ->
        {:reply, :error, state}

      Map.has_key?(state.joined_players, secret_token) ->
        {:reply, :error, state}

      true ->
        [role | remaining] = state.remaining_cards

        is_guardian = role == :guardian

        reply = %{
          playerIds: 1..state.playerCount |> Enum.to_list(),
          guardian: is_guardian
        }

        joined_players = Map.put(state.joined_players, secret_token, "")

        {:reply, {:ok, reply},
         %{state | remaining_cards: remaining, joined_players: joined_players}}
    end
  end

  defp starting_roles(3), do: [:guardian, :guardian, :adventurer, :adventurer]
end

defmodule SchreckensWeb.GameController do
  use SchreckensWeb, :controller

  alias Schreckens.Game

  def start(conn, %{"playerCount" => playerCount}) when playerCount >= 3 and playerCount <= 10 do
    {:ok, _pid} = Game.start_link(playerCount: playerCount)

    json(conn, "ok")
  end

  def start(conn, _param), do: error(conn)

  def join(conn, %{"secretToken" => secretToken}) when is_binary(secretToken) do
    case Process.whereis(Game) do
      pid when is_pid(pid) ->
        case Game.join_state(secretToken) do
          {:ok, join_state} -> json(conn, join_state)
          :error -> error(conn)
        end

      _ ->
        error(conn)
    end
  end

  def join(conn, _param), do: error(conn)

  defp error(conn) do
    conn
    |> put_status(400)
    |> json("error")
  end
end
