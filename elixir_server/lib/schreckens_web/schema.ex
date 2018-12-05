defmodule Lobby do
  def games() do
    [%{id: 1, name: "test", description: "foobar"}]
  end
end

defmodule SchreckensWeb.Schema do
  use Absinthe.Schema

  query do
    field :lobby, :lobby do
      resolve(fn _, _, _ ->
        {:ok, %{games: Lobby.games()}}
      end)
    end
  end

  object :lobby do
    field(:games, list_of(:game))
  end

  object :game do
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
  end
end
