FROM bitwalker/alpine-elixir:1.7.4 as builder

ENV MIX_ENV=prod

WORKDIR /app

COPY ./mix.lock /app
COPY ./mix.exs /app

RUN mix do local.hex --force, \
           local.rebar --force, \
           deps.get, \
           deps.compile

COPY . /app

RUN mix do phx.digest, release --env=prod

FROM alpine:3.7

RUN apk add --no-cache \
      ncurses-libs \
      zlib \
      ca-certificates \
      openssl \
      bash  && \
      update-ca-certificates --fresh

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/schreckens/releases/0.1.0/schreckens.tar.gz /app

RUN tar -xzf schreckens.tar.gz; rm schreckens.tar.gz

CMD trap exit TERM; REPLACE_OS_VARS=true /app/bin/schreckens foreground & wait
