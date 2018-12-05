defmodule SchreckensWeb.Router do
  use SchreckensWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SchreckensWeb do
    pipe_through :api

    post "/start", GameController, :start
    post "/stop", GameController, :stop
    post "/join", GameController, :join
    get "/my-rooms/:secret_token", GameController, :my_rooms
    get "/table", GameController, :table
    post "/open", GameController, :open
  end

  scope "/" do
    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: SchreckensWeb.Schema,
            interface: :simple,
            json_codec: Jason
  end
end
