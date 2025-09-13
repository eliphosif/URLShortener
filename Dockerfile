# Stage 1: Build the Go binary
FROM golang:1.21 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o short_url ./cmd/main.go

# Stage 2: Minimal runtime image with non-root user
FROM alpine:latest

RUN apk --no-cache add ca-certificates

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /home/appuser

# Copy binary from builder
COPY --from=builder /app/short_url .

# Set ownership and permissions
RUN chown appuser:appgroup short_url

# Switch to non-root user
USER appuser

EXPOSE 8080
CMD ["./short_url"]
