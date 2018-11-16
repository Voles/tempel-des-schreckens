open Tea.App;
open Tea.Html;

type model = {
  secretToken: string,
  gameState: option(gameState),
}
and gameState = {guardian: bool};

type joined = {
  guardian: bool,
  /* room: list(room) */
}
and room =
  | Closed
  | Empty
  | Treasure
  | Trap;
/*
 UPDATE
 */
[@bs.deriving {accessors: accessors}]
type msg =
  | JoinGame
  | JoinedGame(joined);

let apiJoin = model => {
  let decodeJoined = json =>
    Json.Decode.{guardian: json |> field("guardian", bool)};
  Js.Promise.(
    Fetch.fetchWithInit(
      "https://6f819b47.ngrok.io/join",
      Fetch.RequestInit.make(
        ~method_=Post,
        ~body=
          Fetch.BodyInit.make("{secretToken: \"token\"}"),
        ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
        (),
      ),
    )
    |> then_(Fetch.Response.json)
    |> then_(json => json |> decodeJoined |> resolve)
  );
};

let update = (model, msg) =>
  switch (msg) {
  | JoinGame => (
      model,
      Tea.Cmd.call(callbacks =>
        Js.Promise.(
          apiJoin(model)
          |> then_(joined => {
               let msg = JoinedGame(joined);
               callbacks^.enqueue(msg);
               resolve();
             })
          |> ignore
        )
      ),
    )
  | JoinedGame(joined) => (
      {...model, gameState: Some({guardian: joined.guardian})},
      Tea.Cmd.none,
    )
  };

let view_button = (title, msg) => button([onClick(msg)], [text(title)]);

let view = model =>
  div(
    [],
    [
      nav([], [br([]), view_button("Join", JoinGame)]),
      div([], [span([], [text(model.secretToken)])]),
    ],
  );

let init = () => (
  {secretToken: "secretReasonToken", gameState: None},
  Tea.Cmd.none,
);

let subscriptions = _model => Tea.Sub.none;

let main = standardProgram({init, update, view, subscriptions});