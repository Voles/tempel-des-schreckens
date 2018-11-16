defmodule SchreckensWeb.Router do
  use SchreckensWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SchreckensWeb do
    pipe_through :api

    post "/start", GameController, :start
    post "/join", GameController, :join
    get "/my-rooms/:secret_token", GameController, :my_rooms
  end
end
