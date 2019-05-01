FROM elixir:1.8.1 as builder
WORKDIR /var/app

ENV MIX_ENV prod

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y --no-install-recommends nodejs && rm -rf /var/lib/apt/lists/*

# install hex && rebar
RUN mix local.hex --force && mix local.rebar --force

# pre install elixir deps
ADD mix.exs /var/app
ADD mix.lock /var/app
RUN mix deps.get --only prod

# pre install node deps
ADD assets/package.json /var/app/assets/package.json
ADD assets/package-lock.json /var/app/assets/package-lock.json
RUN npm install --prefix assets

ADD . /var/app
RUN mix compile
RUN cd assets && npm run deploy
RUN mix phx.digest

RUN mix release

FROM elixir:1.8.1-slim

WORKDIR /var/app
EXPOSE 4000
ENV MIX_ENV prod

COPY --from=builder /var/app/_build/prod /var/app/_build/prod

CMD _build/prod/rel/hiit_live/bin/hiit_live foreground