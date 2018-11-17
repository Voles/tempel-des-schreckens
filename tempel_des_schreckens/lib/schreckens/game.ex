defmodule Schreckens.Game do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # PUBLIC API

  def join_state(secret_token) do
    GenServer.call(__MODULE__, {:join_state, secret_token})
  end

  def rooms_for(secret_token) do
    GenServer.call(__MODULE__, {:rooms_for, secret_token})
  end

  def table() do
    GenServer.call(__MODULE__, :table)
  end

  def open(secret_token, target_player_id) do
    GenServer.call(__MODULE__, {:open, secret_token, target_player_id})
  end

  # SERVER IMPLEMENTATION

  @impl true
  def init(player_count: player_count) do
    {:ok,
     %{
       player_count: player_count,
       remaining_ids: 1..player_count |> Enum.to_list(),
       remaining_roles: shuffle_starting_roles(player_count),
       remaining_rooms: shuffle_starting_rooms(player_count),
       joined_players: %{},
       player_id_with_key: 1
     }}
  end

  @impl true
  def handle_call({:join_state, secret_token}, _from, state) do
    cond do
      all_players_joined?(state) ->
        {:reply, :error, state}

      Map.has_key?(state.joined_players, secret_token) ->
        {:reply, :error, state}

      true ->
        [role | remaining_roles] = state.remaining_roles
        [id | remaining_ids] = state.remaining_ids
        {rooms, remaining_rooms} = Enum.split(state.remaining_rooms, 5)

        is_guardian = role == :guardian

        reply = %{
          playerIds: 1..state.player_count |> Enum.to_list(),
          guardian: is_guardian,
          key: number_of_joined_players(state) == 0,
          id: id
        }

        joined_players =
          Map.put(state.joined_players, secret_token, %{
            rooms: rooms,
            id: number_of_joined_players(state) + 1
          })

        {:reply, {:ok, reply},
         %{
           state
           | remaining_roles: remaining_roles,
             joined_players: joined_players,
             remaining_rooms: remaining_rooms,
             remaining_ids: remaining_ids
         }}
    end
  end

  @impl true
  def handle_call({:rooms_for, secret_token}, _from, state) do
    case Map.get(state.joined_players, secret_token) do
      %{rooms: rooms} ->
        {:reply, {:ok, rooms}, state}

      nil ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call(:table, _from, state) do
    cond do
      all_players_joined?(state) ->
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

  @impl true
  def handle_call({:open, secret_token, _target_player_id}, _from, state) do
    cond do
      not all_players_joined?(state) ->
        {:reply, :error, state}

      not you_have_the_key?(secret_token, state) ->
        {:reply, :error, state}

      true ->
        {:reply, :ok, state}
    end
  end

  defp all_players_joined?(state),
    do: number_of_joined_players(state) == state.player_count

  defp number_of_joined_players(state), do: Enum.count(Map.keys(state.joined_players))

  defp you_have_the_key?(secret_token, state) do
    with {:ok, id} <- player_id(secret_token, state) do
      state.player_id_with_key == id
    else
      _ -> false
    end
  end

  defp player_id(secret_token, state) do
    case Map.get(state.joined_players, secret_token) do
      %{id: id} -> {:ok, id}
      _ -> :error
    end
  end

  defp shuffle_starting_roles(3),
    do: [:guardian, :guardian, :adventurer, :adventurer] |> Enum.shuffle()

  defp shuffle_starting_rooms(3),
    do:
      [for(_ <- 1..8, do: :empty), for(_ <- 1..5, do: :treasure), for(_ <- 1..2, do: :trap)]
      |> Enum.flat_map(& &1)
end
