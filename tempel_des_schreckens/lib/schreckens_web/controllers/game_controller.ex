defmodule Schreckens.Game do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(playerCount: playerCount) do
    {:ok,
     %{
       playerCount: playerCount
     }}
  end

  def join_state(secret_token) do
    GenServer.call(__MODULE__, {:join_state, secret_token})
  end

  def handle_call({:join_state, secret_token}, _from, state) do
    reply = %{
      playerIds: 1..state.playerCount |> Enum.to_list(),
      guardian: false
    }

    {:reply, reply, state}
  end
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
        join_state = Game.join_state(secretToken)
        json(conn, join_state)

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
