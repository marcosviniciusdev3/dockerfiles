## DESCRIPTION:
Run Grok agent inside container
## USAGE:
```bash
# Build the image
podman build -t grok .
```

```bash
# Run the container
podman run -it --rm --name grok -v grok:/home/grok/.grok -v /path/to/dir:/home/grok/workdir:Z grok:latest
```
