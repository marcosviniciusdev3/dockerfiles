FROM python:3.11-alpine

# Install ffmpeg, git, and Deno (Alpine's musl-native deno package —
# no glibc/musl compatibility issues like with denoland/deno:bin)
# hadolint ignore=DL3018,DL3013,DL3059
RUN apk add --no-cache ffmpeg git deno && \
    python3 -m pip install --no-cache-dir git+https://github.com/yt-dlp/yt-dlp.git

# Set up the output directory
WORKDIR /out

# Make yt-dlp the default command
ENTRYPOINT ["yt-dlp", "-P", "/out"]
