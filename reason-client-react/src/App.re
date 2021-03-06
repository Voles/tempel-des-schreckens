/* The new stdlib additions */
open Belt;

type dog = string;

type state =
  | WaitingToStartGame
  | GameStarted
  | GameStartFailed;

type action =
  | StartGame
  | StartGameFailed
  | StartGameSucceeded;

module Decode = {
  let start = json: string => Json.Decode.string(json);
};

let component = ReasonReact.reducerComponent("FetchExample");

let make = _children => {
  ...component,
  initialState: _state => WaitingToStartGame,
  reducer: (action, _state) =>
    switch (action) {
    | StartGame =>
      ReasonReact.UpdateWithSideEffects(
        WaitingToStartGame,
        (
          self =>
            Js.Promise.(
              Fetch.fetchWithInit(
                "http://localhost:4000/start",
                Fetch.RequestInit.make(
                  ~method_=Post,
                  ~body=Fetch.BodyInit.make("{\"playerCount\": 3}"),
                  ~headers=
                    Fetch.HeadersInit.make({
                      "Content-Type": "application/json",
                    }),
                  (),
                ),
              )
              |> then_(response =>
                   response |> Fetch.Response.status |> resolve
                 )
              |> then_(status =>
                   (
                     switch (status) {
                     | 200 => self.send(StartGameSucceeded)
                     | _ => self.send(StartGameFailed)
                     }
                   )
                   |> resolve
                 )
              |> catch(_err =>
                   Js.Promise.resolve(self.send(StartGameFailed))
                 )
              |> ignore
            )
        ),
      )
    | StartGameSucceeded => ReasonReact.Update(GameStarted)
    | StartGameFailed => ReasonReact.Update(GameStartFailed)
    },

  render: self =>
    switch (self.state) {
    | WaitingToStartGame =>
      <div>
        <button onClick=(_event => self.send(StartGame))>
          {ReasonReact.string("Start game")}
        </button>
      </div>
    | GameStarted => <div> {ReasonReact.string("Game started")} </div>
    | GameStartFailed =>
      <div> {ReasonReact.string("Game start failed")} </div>
    },
};