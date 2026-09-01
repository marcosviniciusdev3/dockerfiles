FROM python:3.11-alpine

# Install ffmpeg, git, and Deno (Alpine's musl-native deno package —
# no glibc/musl compatibility issues like with denoland/deno:bin)
RUN apk add --no-cache ffmpeg git deno

# Install the latest version of yt-dlp
RUN python3 -m pip install git+https://github.com/yt-dlp/yt-dlp.git

# Set up the output directory
WORKDIR /out

# Make yt-dlp the default command
ENTRYPOINT ["yt-dlp", "-P", "/out"]
