defmodule SchreckensWeb.Schema do
  use Absinthe.Schema

  query do
  end

  object :game do
    field :id, :id
    field :name, :string
    field :description, :string
  end
end
