FROM rustlang/rust:nightly-alpine AS builder

RUN apk add --no-cache openssl-dev pkgconfig build-base

WORKDIR /YouTubeTLDR

# Copy source
COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY static ./static

# Compress static files in-place (creates .gz alongside originals)
RUN cd static && gzip -k index.html style.css script.js

# Build the binary
RUN cargo build --release --no-default-features --features rustls-tls

# Runtime stage
FROM alpine:latest

RUN apk add --no-cache openssl

# Copy the compiled binary from builder
COPY --from=builder /YouTubeTLDR/target/release/YouTubeTLDR /usr/local/bin/YouTubeTLDR

# Copy the ORIGINAL static files to runtime (for serving uncompressed fallback if needed)
COPY --from=builder /YouTubeTLDR/static /app/static

WORKDIR /app

# Expose port (match your app's default, usually 8080 or check code)
EXPOSE 8080

CMD ["/usr/local/bin/YouTubeTLDR"]
