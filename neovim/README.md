## DESCRIPTION: Run Neovim in a container

## USAGE:

```bash
# Build the image
podman build -t neovim . 
```

```bash
# Run the container
podman run -it --rm --name neovim -v "$HOME"/.config/nvim:/home/neovim/.config/nvim:ro -v /path/to/dir:/home/neovim/workdir
```
