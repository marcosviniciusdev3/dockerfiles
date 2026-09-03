# Minimal Jellyfin Docker Image for Kubernetes

A lightweight, secure, and production-ready multi-stage Docker image for **[Jellyfin Media Server](https://github.com/jellyfin/jellyfin)** optimized exclusively for **Kubernetes** environments.

---

## 🚀 Why This Minimal Image?

The official Jellyfin container image is ~1.3 GB+ because it bundles extensive legacy hardware acceleration driver stacks (Intel Compute Runtime / NEO OpenCL, Rockchip Mali, VDPAU, Broadcom drivers, legacy graphics libraries, debugging tools, and large font bundles).

In a container orchestration platform like Kubernetes, these extra drivers introduce unnecessary CVE vulnerability exposure, consume unnecessary cluster disk storage, and slow down node image pulls (`ImagePullBackOff` risk during autoscaling).

### Comparison:

| Feature | Official Jellyfin Image | This Minimal Kubernetes Image |
| :--- | :--- | :--- |
| **Uncompressed Image Size** | ~1.35 GB | **~300 MB** (~75% reduction) |
| **Build Architecture** | Single/Monolithic Script | **Multi-Stage Build** (Node.js Alpine + .NET SDK -> Minimal ASP.NET Runtime) |
| **User Privileges** | Root by default | **Non-root user (`UID 1000:1000`)** |
| **Read-Only Root Filesystem** | Requires custom path overrides | **Supported out-of-the-box** (`readOnlyRootFilesystem: true`) |
| **Transcoding Support** | All proprietary GPU runtimes | **`jellyfin-ffmpeg`** (Software + standard VA-API) |
| **Kubernetes Health Probes** | Internal `curl` healthcheck script | **Native K8s HTTP GET `/health` Probes** |

---

## 🏗️ Multi-Stage Build Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Stage 1: web-builder (node:20-alpine)                       │
│ ➔ Clones jellyfin-web                                       │
│ ➔ Runs 'npm ci' & 'npm run build:production'                │
│ ➔ Output: /web (Static Assets)                              │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────┐
│ Stage 2: server-builder (mcr.microsoft.com/dotnet/sdk:8.0)  │
│ ➔ Clones jellyfin server source                             │
│ ➔ Runs 'dotnet publish -c Release -o /server'               │
│ ➔ Output: /server (Compiled DLLs)                           │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────┐
│ Stage 3: runtime (mcr.microsoft.com/dotnet/aspnet:8.0-slim) │
│ ➔ Installs jellyfin-ffmpeg & minimal font dependencies       │
│ ➔ Creates non-root user (UID 1000)                          │
│ ➔ Copies /server and /web artifacts                         │
│ ➔ Exposes port 8096, entrypoint dotnet jellyfin.dll         │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Building the Image

### Standard Build (Latest Stable)
```bash
docker build -t jellyfin-minimal:latest .
```

### Custom Version / Build Arguments
You can customize the target Jellyfin release, .NET version, or base images using build arguments:

```bash
docker build \
  --build-arg JELLYFIN_VERSION=v10.10.6 \
  --build-arg JELLYFIN_WEB_VERSION=v10.10.6 \
  --build-arg DOTNET_VERSION=8.0 \
  --build-arg FFMPEG_PACKAGE=jellyfin-ffmpeg7 \
  -t jellyfin-minimal:10.10.6 .
```

---

## ☸️ Kubernetes Deployment

Pre-configured production Kubernetes manifests are located in the `k8s/` directory:

```
k8s/
├── kustomization.yaml
├── deployment.yaml
├── service.yaml
└── pvc.yaml
```

### 1. Deploy with Kustomize
```bash
kubectl apply -k k8s/
```

### 2. Or Deploy Manifests Individually
```bash
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## 🔒 Security & Best Practices

1. **Non-Root Execution**:
   The container runs under unprivileged UID `1000` and GID `1000` (`jellyfin`).
2. **Read-Only Root Filesystem**:
   Compatible with `securityContext.readOnlyRootFilesystem: true`. Writable directories (`/config`, `/cache`, `/tmp`) are isolated to dedicated volumes.
3. **Capabilities Dropped**:
   All default Linux capabilities are dropped (`drop: ["ALL"]`).
4. **Health & Lifecycle Probes**:
   - `startupProbe`: Allows up to 5 minutes on initial launch for database migrations.
   - `livenessProbe` & `readinessProbe`: Native HTTP checks against `/health` without invoking subshell processes.

---

## 🎥 Hardware Acceleration (Optional)

If your Kubernetes nodes have an Intel / AMD GPU and you want VA-API hardware acceleration:
1. Mount the `/dev/dri` device into the Pod or use a Kubernetes GPU / device plugin (e.g. Intel Device Plugin for Kubernetes).
2. Ensure the container has access to the render group GID via `supplementalGroups` in the Pod's `securityContext`:
   ```yaml
   spec:
     securityContext:
       supplementalGroups: [44, 107] # Typically the 'video' or 'render' GID on host
   ```
