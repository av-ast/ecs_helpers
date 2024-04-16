FROM lukemathwalker/cargo-chef:latest-rust-1.77-alpine3.19 as chef
WORKDIR /ecs_helpers

FROM --platform=$BUILDPLATFORM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder

RUN apk update && apk upgrade && \
  apk add libressl-dev
COPY --from=planner /ecs_helpers/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

COPY . .

RUN cargo build --release

FROM docker:26.0.1-cli-alpine3.19
WORKDIR /app

COPY --from=builder /ecs_helpers/target/release/ecs_helpers /usr/local/bin/ecs_helpers
