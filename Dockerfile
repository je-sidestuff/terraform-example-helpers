# syntax=docker/dockerfile:1

# https://hub.docker.com/r/alpine/terragrunt/tags
ARG TERRAGRUNT_VERSION=1.13.2

FROM alpine/terragrunt:${TERRAGRUNT_VERSION} AS terragrunt

FROM golang:1.23-bookworm

# Install terraform and terragrunt from the alpine/terragrunt image
COPY --from=terragrunt /bin/terraform /usr/local/bin/
COPY --from=terragrunt /bin/terragrunt /usr/local/bin/

# Install basic utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    git \
    make \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy go module files first to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy templates directory (needed for scaffold-and-test.sh)
COPY templates/ ./templates/

# Make the scaffold script executable
RUN chmod +x ./templates/scaffold-and-test.sh

# Set entrypoint to bash for flexibility
ENTRYPOINT ["/bin/bash"]
