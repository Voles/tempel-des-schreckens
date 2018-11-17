defmodule Schreckens.Game do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # PUBLIC API

  def join(secret_token) do
    GenServer.call(__MODULE__, {:join, secret_token})
  end

  def rooms_for(secret_token) do
    GenServer.call(__MODULE__, {:rooms_for, secret_token})
  end

  def table() do
    GenServer.call(__MODULE__, :table)
  end

  def open(secret_token, target_player_id) when is_integer(target_player_id) do
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
       table_state: %{},
       found_rooms: %{
         empty: 0,
         treasure: 0,
         trap: 0
       },
       player_id_with_key: 1
     }}
  end

  @impl true
  def handle_call({:join, secret_token}, _from, state) do
    cond do
      all_players_joined?(state) ->
        {:reply, :error, state}

      Map.has_key?(state.table_state, secret_token) ->
        {:reply, :error, state}

      true ->
        [role | remaining_roles] = state.remaining_roles
        [id | remaining_ids] = state.remaining_ids
        {rooms, remaining_rooms} = Enum.split(state.remaining_rooms, 5)

        is_guardian = role == :guardian

        reply = %{
          playerIds: 1..state.player_count |> Enum.to_list(),
          guardian: is_guardian,
          key: number_of_players_joined(state) == 0,
          id: id
        }

        table_state =
          Map.put(state.table_state, secret_token, %{
            rooms: rooms,
            id: number_of_players_joined(state) + 1
          })

        {:reply, {:ok, reply},
         %{
           state
           | remaining_roles: remaining_roles,
             table_state: table_state,
             remaining_rooms: remaining_rooms,
             remaining_ids: remaining_ids
         }}
    end
  end

  @impl true
  def handle_call({:rooms_for, secret_token}, _from, state) do
    with %{rooms: rooms} <- Map.get(state.table_state, secret_token),
         public_rooms <- Enum.map(rooms, fn {__, room_type} -> room_type end),
         public_rooms = Enum.sort(public_rooms) do
      {:reply, {:ok, public_rooms}, state}
    else
      _ ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call(:table, _from, state) do
    cond do
      all_players_joined?(state) ->
        table = %{
          key: state.player_id_with_key,
          rooms: rooms_per_player_on_table(state),
          found: state.found_rooms
        }

        {:reply, {:ok, table}, state}

      true ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:open, secret_token, target_player_id}, _from, state) do
    cond do
      not all_players_joined?(state) ->
        {:reply, :error, state}

      not you_have_the_key?(secret_token, state) ->
        {:reply, :error, state}

      you_try_to_open_your_own_room?(secret_token, target_player_id, state) ->
        {:reply, :error, state}

      true ->
        state =
          %{
            state
            | player_id_with_key: target_player_id,
              table_state: update_table_state(target_player_id, state)
          }
          |> update_for_end_of_a_round()

        {:reply, :ok, state}
    end
  end

  defp update_for_end_of_a_round(state) do
    all_rooms =
      state.table_state
      |> Map.to_list()
      |> Enum.map(fn {_, %{rooms: rooms}} -> rooms end)
      |> Enum.flat_map(& &1)

    {open_rooms, _closed_rooms} =
      Enum.split_with(all_rooms, fn
        {:open, _} -> true
        _ -> false
      end)

    number_of_open_rooms = Enum.count(open_rooms)

    if number_of_open_rooms == number_of_players_joined(state) do
      found =
        Enum.reduce(open_rooms, state.found_rooms, fn {_, game_state}, found ->
          Map.update(found, game_state, 1, &(&1 + 1))
        end)

      %{state | found_rooms: found}
    else
      state
    end
  end

  defp update_table_state(target_player_id, state) do
    secret_token_for_target = find_secret_token_for_player_id(target_player_id, state)
    joined_player_state = state.table_state[secret_token_for_target]
    %{rooms: rooms} = joined_player_state

    {rooms, _} =
      Enum.map_reduce(rooms, true, fn
        {:closed, game_state}, true -> {{:open, game_state}, false}
        room, should_change -> {room, should_change}
      end)

    Map.put(state.table_state, secret_token_for_target, %{
      joined_player_state
      | rooms: rooms
    })
  end

  defp all_players_joined?(state),
    do: number_of_players_joined(state) == state.player_count

  defp number_of_players_joined(state), do: Enum.count(Map.keys(state.table_state))

  defp you_have_the_key?(secret_token, state) do
    with {:ok, id} <- player_id(secret_token, state) do
      state.player_id_with_key == id
    end
  end

  defp you_try_to_open_your_own_room?(secret_token, target_player_id, state) do
    with {:ok, id} <- player_id(secret_token, state) do
      id == target_player_id
    end
  end

  defp player_id(secret_token, state) do
    case Map.get(state.table_state, secret_token) do
      %{id: id} -> {:ok, id}
      _ -> :error
    end
  end

  def find_secret_token_for_player_id(player_id, state) do
    {secret_token, _} =
      state.table_state
      |> Map.to_list()
      |> Enum.find(fn
        {_, %{id: ^player_id}} -> true
        _ -> false
      end)

    secret_token
  end

  defp rooms_per_player_on_table(%{table_state: table_state}) do
    table_state
    |> Map.to_list()
    |> Enum.map(fn {_, %{id: id, rooms: rooms}} ->
      public_rooms =
        Enum.map(
          rooms,
          fn
            {:closed, _} -> "closed"
            {:open, room_type} -> room_type
          end
        )

      {id, public_rooms}
    end)
    |> Map.new()
  end

  defp shuffle_starting_roles(3),
    do: [:guardian, :guardian, :adventurer, :adventurer] |> Enum.shuffle()

  defp shuffle_starting_rooms(3),
    do:
      [for(_ <- 1..8, do: :empty), for(_ <- 1..5, do: :treasure), for(_ <- 1..2, do: :trap)]
      |> Enum.flat_map(& &1)
      |> Enum.map(fn card_type -> {:closed, card_type} end)
      |> Enum.shuffle()
end
