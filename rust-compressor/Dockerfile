FROM rust:latest AS builder

WORKDIR /usr/src/app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
COPY --from=builder /usr/src/app/target/release/rust-compressor /usr/local/bin/
ENTRYPOINT ["rust-compressor"]
