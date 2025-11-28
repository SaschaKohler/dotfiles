FROM ubuntu:22.04

# Install basic tools that Windsurf needs to connect
RUN apt update && apt install -y \
    curl \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
